// Generated by CoffeeScript 1.4.0
(function() {
  var Entity, World, assert, vows;

  vows = require("vows");

  assert = require("assert");

  World = require("../server/classes/world");

  Entity = require("../server/classes/entity");

  vows.describe("World").addBatch({
    "A World": {
      topic: new World(),
      "can inform about location": {
        "when occupied": {
          topic: function(world) {
            var _this = this;
            world.on("1:1:0", function(_arg) {
              var entity, location;
              location = _arg.location, entity = _arg.entity;
              return _this.callback(null, location, entity);
            });
            world.add(new Entity({
              x: 1,
              y: 1,
              z: 0
            }));
          },
          "is returned": function(error, location, entity) {
            return assert.deepEqual(entity.location, [1, 1, 0]);
          }
        }
      },
      "will collide entities": {
        topic: function(world) {
          var e1, e2,
            _this = this;
          world.add(e1 = new Entity({
            x: 5,
            y: 5,
            z: 0
          }));
          world.add(e2 = new Entity({
            x: 5,
            y: 6,
            z: 0
          }));
          e1.on("collision", function(_arg) {
            var entity, location;
            entity = _arg.entity, location = _arg.location;
            return _this.callback(null, entity, location, e2);
          });
          e2.move(e1.location);
        },
        "and inform them of each other": function(error, entity, location, e2) {
          return assert.equal(entity.id, e2.id);
        },
        "and not move the collider": function(error, entity, location, e2) {
          return assert.notEqual(e2.location, location);
        }
      }
    }
  })["export"](module);

}).call(this);
