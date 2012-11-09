// Generated by CoffeeScript 1.3.3
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
        "when empty": {
          topic: function(world) {
            var _this = this;
            return world.loc("1:1:1", function(entity) {
              return _this.callback("found something", entity);
            });
          }
        },
        "when occupied": {
          topic: function(world) {
            var _this = this;
            world.on("1:1:0", function(location, entity) {
              return _this.callback(null, location, entity);
            });
            world.add(new Entity({
              x: 1,
              y: 1,
              z: 0
            }, world));
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
          }, world));
          world.add(e2 = new Entity({
            x: 5,
            y: 6,
            z: 0
          }, world));
          e1.on("collision", function(entity, location) {
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