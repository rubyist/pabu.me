function update(group, activeAnchor) {
  var topLeft = group.get(".topLeft")[0];
  var bottomRight = group.get(".bottomRight")[0];
  var image = group.get(".image")[0];

  var originalWidth = 545;
  var originalHeight = 270;
  var originalRatio = originalWidth / originalHeight;

  // update anchor positions
  var newWidth = bottomRight.attrs.x - topLeft.attrs.x;
  var newHeight = newWidth / originalRatio;

  if (activeAnchor.getName() === "topLeft") {
    activeAnchor.attrs.y = bottomRight.attrs.y - newHeight;
  } else {
    activeAnchor.attrs.y = topLeft.attrs.y + newHeight;
  }

  image.setPosition(topLeft.attrs.x, topLeft.attrs.y);
  image.setSize(bottomRight.attrs.x - topLeft.attrs.x, bottomRight.attrs.y - topLeft.attrs.y);
}

function addAnchor(group, x, y, name, invisible) {
  var stage = group.getStage();
  var layer = group.getLayer();

  var anchor = new Kinetic.Circle({
    x: x,
    y: y,
    stroke: "#666",
    fill: "#ddd",
    strokeWidth: 2,
    radius: 8,
    name: name,
    draggable: true
  });

  anchor.on("dragmove", function() {
    update(group, this);
    layer.draw();
  });
  anchor.on("mousedown touchstart", function() {
    group.draggable(false);
    this.moveToTop();
    this.hide();
  });
  anchor.on("dragend", function() {
    group.draggable(true);
    this.show();
    layer.draw();
  });
  // add hover styling
  anchor.on("mouseover", function() {
    var layer = this.getLayer();
    document.body.style.cursor = "pointer";
    this.setStrokeWidth(4);
    layer.draw();
  });
  anchor.on("mouseout", function() {
    var layer = this.getLayer();
    document.body.style.cursor = "default";
    this.setStrokeWidth(2);
    layer.draw();
  });

  group.add(anchor);
}

function pabuGO(imageUrl, width, height) {
  var stage = new Kinetic.Stage({
    container: "pabu",
    width: width,
    height: height
  });

  var pandaGroup = new Kinetic.Group({x: 50, y: 50, draggable: true});
  var layer = new Kinetic.Layer();
  layer.add(pandaGroup);
  stage.add(layer);

  var backgroundSource = new Image();
  backgroundSource.onload = function() {
    var backgroundImg = new Kinetic.Image({
      x: 0,
      y: 0,
      image: backgroundSource,
      width: width,
      height: height,
      name: "image"
    });
    layer.add(backgroundImg);
    layer.draw();
  }
  backgroundSource.src = imageUrl;

  var pandaSource = new Image();
  pandaSource.onload = function() {
    var pandaImg = new Kinetic.Image({
      x: 0,
      y: 0,
      image: pandaSource,
      width: 550,
      height: 270,
      name: "image"
    });
    pandaGroup.add(pandaImg);
    pandaGroup.moveToTop();
    layer.draw();
  }
  pandaSource.src = './images/pabu.gif';

  addAnchor(pandaGroup, 0, 0, "topLeft");
  addAnchor(pandaGroup, 550, 270, "bottomRight");

  stage.draw();
};
