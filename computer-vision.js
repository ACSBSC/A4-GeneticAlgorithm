window.onload = function() {
  const pictureImg = document.querySelector("img.input-picture");
  const inputPicture = document.querySelector("input#input-picture");
  const prediction = document.querySelector("span.vision-result");
  var errorMessage = document.querySelector("#error-message");
  var debugTraces = document.querySelector("#debug-traces");
  let loadingImg = document.querySelector('.loading-img');
  let inputWidth, inputHeight;
  const THRESH_CONFIDENCE = 80, THRESH_EYES_DEVIATION = 35, THRESH_PAN_TILT_ROLL = 11;
  let result = {};


function removeChildren(parent) {
    while (parent.lastChild) {
      parent.removeChild(parent.lastChild);
    }
}

function logMessage(container, message, instructions = '', error = true) {
  container.appendChild(document.createElement("p"));
  container.lastChild.textContent = message;
  if(instructions && instructions != '') {
    let wrapper = document.createElement("span");
    wrapper.textContent = " : " + instructions;
    wrapper.className = "warning-message";
    container.lastChild.appendChild(wrapper);
  }
  container.lastChild.className = error ? "error-message" : "positive-message";
}

  function blobToBase64(blob) {
    return new Promise((resolve, _) => {
      const reader = new FileReader();
      reader.onloadend = () => resolve(reader.result);
      reader.readAsDataURL(blob);
    });
  }

  function getRegionOfInterest(landmarks) {
    let top, right, bottom, left;
    landmarks.forEach(landmark => {
      if(landmark.type.endsWith("TOP_BOUNDARY")) {
        top = landmark.position.y;
      } else if(landmark.type.endsWith("RIGHT_CORNER")) {
        right = landmark.position.x;
      } else if(landmark.type.endsWith("BOTTOM_BOUNDARY")) {
        bottom = landmark.position.y;
      } else if(landmark.type.endsWith("LEFT_CORNER")) {
        left = landmark.position.x;
      }
    });
    return { x: left, y: top, width: right - left, height: bottom - top };
  }

  function isEyeOpen(src, eyesLandmarks, canvas = "canvasOutput") {
    let mean = new cv.Mat;
    let std = new cv.Mat;
    let dst = new cv.Mat;
    let circles = new cv.Mat();

    let roi = getRegionOfInterest(eyesLandmarks);
    console.log(roi);
    if(roi.width < 1 || roi.height < 1) {
      return -1;
    }
    let rect = new cv.Rect(roi.x, roi.y, roi.width, roi.height * 1.2);
    dst = src.roi(rect);
    cv.cvtColor(dst, dst, cv.COLOR_RGBA2GRAY, 0);
    cv.blur(dst, dst, new cv.Size(3, 3));
    cv.HoughCircles(dst, circles, cv.HOUGH_GRADIENT, 1, dst.rows/16, param1 = 40,
                    param2 = 15, minRadius = 1, maxRadius = 70);
    let size = circles.size();
    // cv.imshow(canvas, dst);
    console.log("HoughCircles:");
    console.log(size);
    return size.width > 0 && size.height > 0;
  }

  function getStandardDeviation(src, eyesLandmarks, canvas = "canvasOutput") {
    let mean = new cv.Mat;
    let std = new cv.Mat;
    let roi = getRegionOfInterest(eyesLandmarks);
    console.log(roi);
    if(roi.width < 1 || roi.height < 1) {
      return -1;
    }
    let rect = new cv.Rect(roi.x, roi.y, roi.width, roi.height);
    dst = src.roi(rect);
    cv.meanStdDev(dst, mean, std);
    // cv.imshow(canvas, dst);
    return std.doubleAt(0,0);
  }

  function detectHuman(localizedObjectAnnotations) {
    if(!localizedObjectAnnotations || localizedObjectAnnotations.length <= 0) {
      logMessage(debugTraces, "The image is empty.", "Check if the image is corrupted.");
    } else {
        const objects = localizedObjectAnnotations.map(o => o.name.toLowerCase());
        if(objects.includes("person")) {
            logMessage(debugTraces, "Human detected.", '', false);
            return true;
        }
        logMessage(debugTraces, "No human detected.", "Take a picture of yourself.");
    }
    return false;
  }

  function detectFace(faceAnnotations) {
    if(!faceAnnotations || faceAnnotations.length <= 0) {
      logMessage(debugTraces, "No face detected.", "Make sure your face is clearly visible.");
    } else {
      faceAnnotations.forEach((subset, i) => {
        result.face = 'Yes';
        result.face_confidence = `${subset.detectionConfidence.toFixed(2) * 100}`;
        result.exposed = subset.underExposedLikelihood;
        result.blurred = subset.blurredLikelihood;
        result.roll = subset.rollAngle.toFixed(2);
        result.pan = subset.panAngle.toFixed(2);
        result.tilt = subset.tiltAngle.toFixed(2);
      });
      logMessage(debugTraces, "Face detected.",  '', false);
      return true;
    }
    return false;
  }

  function detectGlasses(localizedObjectAnnotations, labelAnnotations) {
    if(!localizedObjectAnnotations && localizedObjectAnnotations.length <= 0 ||
      !labelAnnotations && labelAnnotations.length <= 0) {
      return false;
    }
    var objects = localizedObjectAnnotations.map(o => o.name.toLowerCase());
    var labels = labelAnnotations.map(o => o.description.toLowerCase());
    if(objects.includes("glasses") || labels.includes("glasses")) {
      logMessage(debugTraces, "Glasses detected.", "Remove your glasses.");
      return true;
    }
    return false;
  }

  function detectFaceFeatures(labelAnnotations, faceConfidence) {
    if(faceConfidence >= THRESH_CONFIDENCE) {
      return true;
    }
    logMessage(debugTraces, `Confidence < ${THRESH_CONFIDENCE} %`);
    logMessage(debugTraces, `-> Checking all face features.`);

    if(labelAnnotations && labelAnnotations.length > 0) {
      const requiredLabels = ["nose", "cheek", "eyebrow", "eyelash", "jaw"];
      const requiredLabels2 = ["mouth", "lip"];
      const labels = labelAnnotations.map(o => o.description.toLowerCase());
      if(requiredLabels.every(label => labels.includes(label)) &&
          requiredLabels2.some(label => labels.includes(label)))
      {
          logMessage(debugTraces, "--> All face features detected (nose,cheek,eyebrow,eyelash,mouth,jaw,lip).",  '', false);
          return true;
      }
    }
    logMessage(debugTraces, "--> Missing some face features (nose,cheek,eyebrow,eyelash,mouth,jaw or lip).", "Make sure your face is clearly visible.");
    return false;
  }

  function detectCoveredFace(labelAnnotations) {
    if(!labelAnnotations || labelAnnotations.length <= 0) {
      return false;
    }

    const objects = labelAnnotations.map(o => o.description.toLowerCase());
    if(objects.includes("bangs")) {
      logMessage(debugTraces, "Hair covering face.", "Make sure your face is clearly visible.");
      return true;
    }
    return false;
  }

  function detectFrontFace(roll, tilt, pan) {
    if(Math.abs(roll) > THRESH_PAN_TILT_ROLL || 
      Math.abs(tilt) > THRESH_PAN_TILT_ROLL || 
      Math.abs(pan > THRESH_PAN_TILT_ROLL))
    {
      logMessage(debugTraces, "Not a front-face picture.", "Face the camera.");
      return false;
    }

    logMessage(debugTraces, "Is a front face picture.",  '', false);
    return true;
  }

  function detectOpenedEyes(faceAnnotations) {
    if(!faceAnnotations || !faceAnnotations[0].landmarks) {
      logMessage(debugTraces, "Cannot find the eyes.",  "Make sure your face is clearly visible.");
      return false;
    } else {
      const landmarks = faceAnnotations[0].landmarks;
      var landmarksNames = [ "LEFT_EYE", "RIGHT_EYE", "LEFT_EYE_TOP_BOUNDARY",
                            "LEFT_EYE_RIGHT_CORNER", "LEFT_EYE_BOTTOM_BOUNDARY",
                            "LEFT_EYE_LEFT_CORNER", "RIGHT_EYE_TOP_BOUNDARY",
                            "RIGHT_EYE_RIGHT_CORNER", "RIGHT_EYE_BOTTOM_BOUNDARY",
                            "RIGHT_EYE_LEFT_CORNER"
                          ];
      var eyesLandmarks = landmarks.filter(landmark => landmarksNames.includes(landmark.type));
      var eyesLandmarksRight = eyesLandmarks.filter(landmark => landmark.type.startsWith("RIGHT"));
      var eyesLandmarksLeft = eyesLandmarks.filter(landmark => landmark.type.startsWith("LEFT"));
      console.log(`Original size : ${inputWidth} ${inputHeight}`);
      let src = cv.imread(pictureImg);
      console.log(`imread size : ${src.size().width} ${src.size().height}`);
      let dsize = new cv.Size(inputWidth, inputHeight);
      cv.resize(src, src, dsize, 0, 0, cv.INTER_LINEAR);
      console.log(`Final size : ${src.size().width} ${src.size().height}`);
      // cv.imshow('canvasOutput', src);
      console.log(eyesLandmarksLeft);
      console.log(eyesLandmarksRight);
      let isOpenLeft = isEyeOpen(src, eyesLandmarksLeft);
      let isOpenRight = isEyeOpen(src, eyesLandmarksRight, "canvasOutput2");
      if(!isOpenLeft && !isOpenRight) {
        logMessage(debugTraces, "Eyes closed.", "Look at the camera.");
        return false;
      } else {
        logMessage(debugTraces, "Eyes opened.", '', false);
        return true;
      }
      // let deviationLeft = getStandardDeviation(src, eyesLandmarksLeft);
      // let deviationRight = getStandardDeviation(src, eyesLandmarksRight, "canvasOutput2");
      // if(deviationLeft < THRESH_EYES_DEVIATION || deviationRight < THRESH_EYES_DEVIATION) {
      //   result.prediction = false;
      //   errorMessage.textContent += "Eye(s) closed | ";
      // }
      // console.log(`Standard deviation : ${deviationLeft} ${deviationRight}`);
    }
  }

  function annotateImage(bytes) {
    bytes = bytes.replace(/^data:image\/(png|jpg|jpeg);base64,/, "");
    let url = `https://vision.googleapis.com/v1/images:annotate?key=${API_KEY_VISION}`;
    let features = [ { type: 'FACE_DETECTION', maxResults: 1 },
    { type: 'LABEL_DETECTION', maxResults: 25 },
    { type: 'OBJECT_LOCALIZATION', maxResults: 3 } ];
    var data = {};
    data.requests = [ { image: { content: bytes}, features: features} ];

    fetch(url, {
      method: 'POST',
      mode: 'cors',
      cache: 'no-cache',
      credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data) // body data type must match "Content-Type" header
    })
    .then(response => response.json())
    .then(data => {
      // process result
      if(data.error) {
        // errorMessage.textContent += JSON.stringify(data.error);
        logMessage(debugTraces, JSON.stringify(data.error));
        loadingImg.style.display = "none";
        return;
      }
      data = data.responses[0];
      console.log(data);
      result = {};
      result.prediction = true;
      // errorMessage.textContent = "";
      removeChildren(debugTraces);
      logMessage(debugTraces, "...Starting analysis",  '', false);

      let containsHuman = detectHuman(data.localizedObjectAnnotations);
      let containsFace = detectFace(data.faceAnnotations);
      let containsAllFaceFeatures = detectFaceFeatures(data.labelAnnotations, result.face_confidence);
      let containsGlasses = detectGlasses(data.localizedObjectAnnotations, data.labelAnnotations);
      let containsOcclusions = detectCoveredFace(data.labelAnnotations);
      let containsFrontFace = detectFrontFace(result.roll, result.tilt, result.pan);
      let containsOpenedEyes = detectOpenedEyes(data.faceAnnotations);

      if((containsGlasses || containsOcclusions) && containsAllFaceFeatures) {
        logMessage(debugTraces, "Glasses OR hair covering face detected BUT all face features detected.",  '', false);
        containsGlasses = containsOcclusions = false;
      }

      result.prediction = containsHuman && containsFace && containsAllFaceFeatures
      && !containsGlasses && !containsOcclusions && containsFrontFace && containsOpenedEyes;

      // document.querySelector("#result-face").textContent = result.face;
      // document.querySelector("#result-exposed").textContent = result.exposed;
      // document.querySelector("#result-blurred").textContent = result.blurred;
      // document.querySelector("#result-roll").textContent = `${result.roll} °`;
      // document.querySelector("#result-pan").textContent = `${result.pan} °`;
      // document.querySelector("#result-tilt").textContent = `${result.tilt} °`;
      // document.querySelector("#result-person").textContent = result.person;
      // document.querySelector("#result-glasses").textContent = result.glasses;
      // document.querySelector("#result-hair").textContent = result.hair;
      // document.querySelector("#result-front-face").textContent = result.front_face;
      prediction.textContent = ": ";
      prediction.textContent += result.prediction ? "ACCEPTED" : "DISCARDED";
      prediction.textContent += ` (confidence : ${result.face_confidence} %)`;
      loadingImg.style.display = "none";
      errorMessage.textContent = "";
      logMessage(debugTraces, "...End of  analysis",  '', false);
    })
    .catch((error) => {
      console.error('Error:', error);
      // errorMessage.textContent += JSON.stringify(error);
      logMessage(debugTraces, JSON.stringify(error));
      loadingImg.style.display = "none";
    });
    // return response.json(); // parses JSON response into native JavaScript objects
  }

  async function updatePicture(e) {
    // console.log(e);
    // console.log(inputPicture);
    const [file] = inputPicture.files;
    if(file) {
      loadingImg.style.display = "inherit";
      // console.log(file);
      source = URL.createObjectURL(file);
      // console.log(source);
      pictureImg.onload = function() {
        inputWidth = pictureImg.naturalWidth;
        inputHeight = pictureImg.naturalHeight;
    }
      pictureImg.src = source;
      annotateImage(await blobToBase64(file));
    }
  }

  fetchCookies();
  inputPicture.addEventListener('change', updatePicture);
}

function onOpenCvReady() {
  console.log('OpenCV.js is ready.');
}
