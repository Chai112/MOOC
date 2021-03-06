const Db = require('./database');
const Token = require('./token');
const CourseSections = require('./courseSections');
const VideoData = require('./videoData');


var courseElements = new Db.DatabaseTable("CourseElements",
    "courseElementId",
    [
        {
        name: "courseSectionId",
        type: "int"
        },
        {
        name: "courseElementName",
        type: "varchar(50)"
        },
        {
        name: "courseElementDescription",
        type: "varchar(256)"
        },
        {
        name: "courseElementType",
        type: "int"
        },
        /*
        courseElementType
        0 - video
        1 - literature
        2 - forms
        */
        {
        name: "elementOrder",
        type: "int"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
]);
courseElements.init();

var videos = new Db.DatabaseTable("Videos",
    "videoId",
    [
        {
        name: "courseElementId",
        type: "int"
        },
        {
        name: "duration",
        type: "int"
        },
        {
        name: "videoDataId",
        type: "varchar(16)"
        },
        {
        name: "isInitialized",
        type: "bit"
        },
        {
        name: "isUploading",
        type: "bit"
        },
        {
        name: "videoData",
        type: "mediumtext"
        },
]);
videos.init();

var literature = new Db.DatabaseTable("Literature",
    "literatureId",
    [
        {
        name: "courseElementId",
        type: "int"
        },
        {
        name: "literatureData",
        type: "mediumtext"
        },
]);
literature.init();

var forms = new Db.DatabaseTable("Forms",
    "formId",
    [
        {
        name: "courseElementId",
        type: "int"
        },
        {
        name: "formData",
        type: "mediumtext"
        },
]);
forms.init();

module.exports.DO_NOT_RUN_FULL_RESET = DO_NOT_RUN_FULL_RESET;
async function DO_NOT_RUN_FULL_RESET() {
    await courseElements.drop();
    await courseElements.init();
    await videos.drop();
    await videos.init();
    await literature.drop();
    await literature.init();
    await forms.drop();
    await forms.init();
}

module.exports.createVideo = createVideo;
async function createVideo (token, courseSectionId, videoOptions) {
    // check auth
    await CourseSections.assertUserCanEditCourseSection(token, courseSectionId);

    let courseElementId = await _addCourseElement(courseSectionId, videoOptions, 0);

    // create video
    var videoDataId = Token.generateToken();

    let videoId = await videos.insertInto({
        courseElementId: courseElementId,
        videoDataId: videoDataId,
        duration: 0,
        isInitialized: false,
        isUploading: false,
        videoData: "",
    });

    return courseElementId;
}

module.exports.createLiterature = createLiterature;
async function createLiterature (token, courseSectionId, literatureOptions) {
    // check auth
    await CourseSections.assertUserCanEditCourseSection(token, courseSectionId);

    let courseElementId = await _addCourseElement(courseSectionId, literatureOptions, 1);

    let literatureId = await literature.insertInto({
        courseElementId: courseElementId,
        literatureData: literatureOptions.literatureData,
    });

    return courseElementId;
}

module.exports.createForm = createForm;
async function createForm (token, courseSectionId, formOptions) {
    // check auth
    await CourseSections.assertUserCanEditCourseSection(token, courseSectionId);

    let courseElementId = await _addCourseElement(courseSectionId, formOptions, 2);

    let formId = await forms.insertInto({
        courseElementId: courseElementId,
        formData: formOptions.formData,
    });

    return courseElementId;
}

module.exports.getVideo = getVideo;
async function getVideo (token, courseElementId) {
    // TODO: do auth checks
    return await videos.select({courseElementId: courseElementId});
}
module.exports.getLiterature = getLiterature;
async function getLiterature (token, courseElementId) {
    // TODO: do auth checks
    return await literature.select({courseElementId: courseElementId});
}
module.exports.getForm = getForm;
async function getForm (token, courseElementId) {
    // TODO: do auth checks
    return await forms.select({courseElementId: courseElementId});
}

module.exports.getAllElementsFromCourseSection = getAllElementsFromCourseSection;
async function getAllElementsFromCourseSection(courseSectionId) {
    let elementOutput = await courseElements.select({ courseSectionId: courseSectionId });
    let output = [];

    for (let i = 0; i < elementOutput.length; i++) {
        output.push(elementOutput[i]);
    }
    return output;
}

module.exports.changeCourseElement = changeCourseElement;
async function changeCourseElement (token, courseElementId, courseElementOptions) {
    let courseElement = await courseElements.select({courseElementId: courseElementId});
    let courseSectionId = courseElement[0].courseSectionId;
    // check auth
    await CourseSections.assertUserCanEditCourseSection(token, courseSectionId);

    await courseElements.update(
        { courseElementId: courseElementId },
        {
            courseElementName: courseElementOptions.courseElementName,
            courseElementDescription: courseElementOptions.courseElementDescription,
        }
    );
}

module.exports.removeCourseElement = removeCourseElement;
async function removeCourseElement (token, courseElementId) {
    let courseElement = await courseElements.select({courseElementId: courseElementId});
    let courseSectionId = courseElement[0].courseSectionId;
    // check auth
    await CourseSections.assertUserCanEditCourseSection(token, courseSectionId);

    await _removeElementOrder(courseElement[0].courseElementOrder, courseSectionId)

    // gotta do a remove specially for videos
    video = await videos.select({courseElementId: courseElementId});
    if (video.length > 0) {
        VideoData.removeVideo(video[0].videoDataId);
    }

    await videos.deleteFrom({courseElementId: courseElementId});
    await literature.deleteFrom({courseElementId: courseElementId});
    await forms.deleteFrom({courseElementId: courseElementId});
    await courseElements.deleteFrom({courseElementId: courseElementId});
}

module.exports.removeAllCourseElementsFromCourseSection = removeAllCourseElementsFromCourseSection;
async function removeAllCourseElementsFromCourseSection(courseSectionId) {
    let data = await courseElements.select({courseSectionId: courseSectionId});
    for (let i = 0; i < data.length; i++) {
        await videos.deleteFrom({courseElementId: data[i].courseElementId});
        await literature.deleteFrom({courseElementId: data[i].courseElementId});
        await forms.deleteFrom({courseElementId: data[i].courseElementId});
    }
    await courseElements.deleteFrom({courseSectionId: courseSectionId});
}

async function _addCourseElement (courseSectionId, courseElementOptions, courseElementType) {
    // determine next element order
    let elementOrder = await _getNextElementOrder(courseSectionId);

    let courseElementId = await courseElements.insertInto({
        courseSectionId: courseSectionId,
        courseElementName: courseElementOptions.courseElementName,
        courseElementDescription: courseElementOptions.courseElementDescription,
        courseElementType: courseElementType,
        elementOrder: elementOrder,
        dateCreated: Db.getDatetime(),
    });

    return courseElementId;
}

async function _getNextElementOrder (courseSectionId) {
    let elementOrder = await courseElements.selectMax("elementOrder", { courseSectionId: courseSectionId });

    // check if even any elements exists
    if (elementOrder.elementOrder === null) {
        return 0;
    }
    return elementOrder.elementOrder + 1;
}

async function _removeElementOrder (elementOrder, courseSectionId) {
    let ce = await courseElements.select({courseSectionId: courseSectionId});
    for (let i = 0; i < ce.length; i++) {
        if (ce[i].elementOrder > elementOrder) {
            await courseElements.update(
                { courseElementId: ce[i].courseElementId },
                { elementOrder: ce[i].elementOrder - 1 }
            );
        }
    }
}

// 0: [ Alice ]
// 1: [ Bob ]
// 2: [ Charlie ]
// 3: [ Derek ]
// 4: [ Franky ]
// move Bob to index 3 (toSectionOrder = 3, currentSectionOrder = 1)
// 0: [ Alice ]
// 1: [ Charlie ]
// 2: [ Derek ]
// 3: [ Bob ]
// 4: [ Franky ]
// 
// step 1: remove the currentSectionOrder
// step 2: anything above or equal toSectionOrder, shift up by one
// step 3: insert into

module.exports.moveCourseElement = moveCourseElement;
async function moveCourseElement(courseElementId, toElementOrder) {
    let courseElement = (await courseElements.select({courseElementId: courseElementId}))[0];
    let currentElementOrder = courseElement.elementOrder;
    let courseSectionId = courseElement.courseSectionId;

    // step 1: remove the currentSectionOrder
    await _removeElementOrder(currentElementOrder, courseSectionId);

    // step 2: anything above toSectionOrder, shift up by one
    let ce = await courseElements.select({courseSectionId: courseSectionId});
    for (let i = 0; i < ce.length; i++) {
        if (ce[i].elementOrder >= toElementOrder) {
            await courseElements.update(
                { courseElementId: ce[i].courseElementId },
                { elementOrder: ce[i].elementOrder + 1 }
            );
        }
    }

    // step 3: insert into
    await courseElements.update(
        { courseElementId: courseElementId },
        { elementOrder: toElementOrder }
    );
}

module.exports.updateUploadingVideo = updateUploadingVideo;
async function updateUploadingVideo (videoDataId, isUploading) {
    console.log("copy")
    await videos.update(
        { videoDataId: videoDataId }, 
        { isUploading: isUploading }
    );
    if (!isUploading) {
        console.log("done uploading " + videoDataId)
        await videos.update(
            { videoDataId: videoDataId }, 
            { isInitialized: true }
        );
    }
}