(function(){var require = function (file, cwd) {
    var resolved = require.resolve(file, cwd || '/');
    var mod = require.modules[resolved];
    if (!mod) throw new Error(
        'Failed to resolve module ' + file + ', tried ' + resolved
    );
    var cached = require.cache[resolved];
    var res = cached? cached.exports : mod();
    return res;
};

require.paths = [];
require.modules = {};
require.cache = {};
require.extensions = [".js",".coffee",".json"];

require._core = {
    'assert': true,
    'events': true,
    'fs': true,
    'path': true,
    'vm': true
};

require.resolve = (function () {
    return function (x, cwd) {
        if (!cwd) cwd = '/';
        
        if (require._core[x]) return x;
        var path = require.modules.path();
        cwd = path.resolve('/', cwd);
        var y = cwd || '/';
        
        if (x.match(/^(?:\.\.?\/|\/)/)) {
            var m = loadAsFileSync(path.resolve(y, x))
                || loadAsDirectorySync(path.resolve(y, x));
            if (m) return m;
        }
        
        var n = loadNodeModulesSync(x, y);
        if (n) return n;
        
        throw new Error("Cannot find module '" + x + "'");
        
        function loadAsFileSync (x) {
            x = path.normalize(x);
            if (require.modules[x]) {
                return x;
            }
            
            for (var i = 0; i < require.extensions.length; i++) {
                var ext = require.extensions[i];
                if (require.modules[x + ext]) return x + ext;
            }
        }
        
        function loadAsDirectorySync (x) {
            x = x.replace(/\/+$/, '');
            var pkgfile = path.normalize(x + '/package.json');
            if (require.modules[pkgfile]) {
                var pkg = require.modules[pkgfile]();
                var b = pkg.browserify;
                if (typeof b === 'object' && b.main) {
                    var m = loadAsFileSync(path.resolve(x, b.main));
                    if (m) return m;
                }
                else if (typeof b === 'string') {
                    var m = loadAsFileSync(path.resolve(x, b));
                    if (m) return m;
                }
                else if (pkg.main) {
                    var m = loadAsFileSync(path.resolve(x, pkg.main));
                    if (m) return m;
                }
            }
            
            return loadAsFileSync(x + '/index');
        }
        
        function loadNodeModulesSync (x, start) {
            var dirs = nodeModulesPathsSync(start);
            for (var i = 0; i < dirs.length; i++) {
                var dir = dirs[i];
                var m = loadAsFileSync(dir + '/' + x);
                if (m) return m;
                var n = loadAsDirectorySync(dir + '/' + x);
                if (n) return n;
            }
            
            var m = loadAsFileSync(x);
            if (m) return m;
        }
        
        function nodeModulesPathsSync (start) {
            var parts;
            if (start === '/') parts = [ '' ];
            else parts = path.normalize(start).split('/');
            
            var dirs = [];
            for (var i = parts.length - 1; i >= 0; i--) {
                if (parts[i] === 'node_modules') continue;
                var dir = parts.slice(0, i + 1).join('/') + '/node_modules';
                dirs.push(dir);
            }
            
            return dirs;
        }
    };
})();

require.alias = function (from, to) {
    var path = require.modules.path();
    var res = null;
    try {
        res = require.resolve(from + '/package.json', '/');
    }
    catch (err) {
        res = require.resolve(from, '/');
    }
    var basedir = path.dirname(res);
    
    var keys = (Object.keys || function (obj) {
        var res = [];
        for (var key in obj) res.push(key);
        return res;
    })(require.modules);
    
    for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        if (key.slice(0, basedir.length + 1) === basedir + '/') {
            var f = key.slice(basedir.length);
            require.modules[to + f] = require.modules[basedir + f];
        }
        else if (key === basedir) {
            require.modules[to] = require.modules[basedir];
        }
    }
};

(function () {
    var process = {};
    var global = typeof window !== 'undefined' ? window : {};
    var definedProcess = false;
    
    require.define = function (filename, fn) {
        if (!definedProcess && require.modules.__browserify_process) {
            process = require.modules.__browserify_process();
            definedProcess = true;
        }
        
        var dirname = require._core[filename]
            ? ''
            : require.modules.path().dirname(filename)
        ;
        
        var require_ = function (file) {
            var requiredModule = require(file, dirname);
            var cached = require.cache[require.resolve(file, dirname)];

            if (cached && cached.parent === null) {
                cached.parent = module_;
            }

            return requiredModule;
        };
        require_.resolve = function (name) {
            return require.resolve(name, dirname);
        };
        require_.modules = require.modules;
        require_.define = require.define;
        require_.cache = require.cache;
        var module_ = {
            id : filename,
            filename: filename,
            exports : {},
            loaded : false,
            parent: null
        };
        
        require.modules[filename] = function () {
            require.cache[filename] = module_;
            fn.call(
                module_.exports,
                require_,
                module_,
                module_.exports,
                dirname,
                filename,
                process,
                global
            );
            module_.loaded = true;
            return module_.exports;
        };
    };
})();


require.define("path",function(require,module,exports,__dirname,__filename,process,global){function filter (xs, fn) {
    var res = [];
    for (var i = 0; i < xs.length; i++) {
        if (fn(xs[i], i, xs)) res.push(xs[i]);
    }
    return res;
}

// resolves . and .. elements in a path array with directory names there
// must be no slashes, empty elements, or device names (c:\) in the array
// (so also no leading and trailing slashes - it does not distinguish
// relative and absolute paths)
function normalizeArray(parts, allowAboveRoot) {
  // if the path tries to go above the root, `up` ends up > 0
  var up = 0;
  for (var i = parts.length; i >= 0; i--) {
    var last = parts[i];
    if (last == '.') {
      parts.splice(i, 1);
    } else if (last === '..') {
      parts.splice(i, 1);
      up++;
    } else if (up) {
      parts.splice(i, 1);
      up--;
    }
  }

  // if the path is allowed to go above the root, restore leading ..s
  if (allowAboveRoot) {
    for (; up--; up) {
      parts.unshift('..');
    }
  }

  return parts;
}

// Regex to split a filename into [*, dir, basename, ext]
// posix version
var splitPathRe = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;

// path.resolve([from ...], to)
// posix version
exports.resolve = function() {
var resolvedPath = '',
    resolvedAbsolute = false;

for (var i = arguments.length; i >= -1 && !resolvedAbsolute; i--) {
  var path = (i >= 0)
      ? arguments[i]
      : process.cwd();

  // Skip empty and invalid entries
  if (typeof path !== 'string' || !path) {
    continue;
  }

  resolvedPath = path + '/' + resolvedPath;
  resolvedAbsolute = path.charAt(0) === '/';
}

// At this point the path should be resolved to a full absolute path, but
// handle relative paths to be safe (might happen when process.cwd() fails)

// Normalize the path
resolvedPath = normalizeArray(filter(resolvedPath.split('/'), function(p) {
    return !!p;
  }), !resolvedAbsolute).join('/');

  return ((resolvedAbsolute ? '/' : '') + resolvedPath) || '.';
};

// path.normalize(path)
// posix version
exports.normalize = function(path) {
var isAbsolute = path.charAt(0) === '/',
    trailingSlash = path.slice(-1) === '/';

// Normalize the path
path = normalizeArray(filter(path.split('/'), function(p) {
    return !!p;
  }), !isAbsolute).join('/');

  if (!path && !isAbsolute) {
    path = '.';
  }
  if (path && trailingSlash) {
    path += '/';
  }
  
  return (isAbsolute ? '/' : '') + path;
};


// posix version
exports.join = function() {
  var paths = Array.prototype.slice.call(arguments, 0);
  return exports.normalize(filter(paths, function(p, index) {
    return p && typeof p === 'string';
  }).join('/'));
};


exports.dirname = function(path) {
  var dir = splitPathRe.exec(path)[1] || '';
  var isWindows = false;
  if (!dir) {
    // No dirname
    return '.';
  } else if (dir.length === 1 ||
      (isWindows && dir.length <= 3 && dir.charAt(1) === ':')) {
    // It is just a slash or a drive letter with a slash
    return dir;
  } else {
    // It is a full dirname, strip trailing slash
    return dir.substring(0, dir.length - 1);
  }
};


exports.basename = function(path, ext) {
  var f = splitPathRe.exec(path)[2] || '';
  // TODO: make this comparison case-insensitive on windows?
  if (ext && f.substr(-1 * ext.length) === ext) {
    f = f.substr(0, f.length - ext.length);
  }
  return f;
};


exports.extname = function(path) {
  return splitPathRe.exec(path)[3] || '';
};

exports.relative = function(from, to) {
  from = exports.resolve(from).substr(1);
  to = exports.resolve(to).substr(1);

  function trim(arr) {
    var start = 0;
    for (; start < arr.length; start++) {
      if (arr[start] !== '') break;
    }

    var end = arr.length - 1;
    for (; end >= 0; end--) {
      if (arr[end] !== '') break;
    }

    if (start > end) return [];
    return arr.slice(start, end - start + 1);
  }

  var fromParts = trim(from.split('/'));
  var toParts = trim(to.split('/'));

  var length = Math.min(fromParts.length, toParts.length);
  var samePartsLength = length;
  for (var i = 0; i < length; i++) {
    if (fromParts[i] !== toParts[i]) {
      samePartsLength = i;
      break;
    }
  }

  var outputParts = [];
  for (var i = samePartsLength; i < fromParts.length; i++) {
    outputParts.push('..');
  }

  outputParts = outputParts.concat(toParts.slice(samePartsLength));

  return outputParts.join('/');
};

});

require.define("__browserify_process",function(require,module,exports,__dirname,__filename,process,global){var process = module.exports = {};

process.nextTick = (function () {
    var canSetImmediate = typeof window !== 'undefined'
        && window.setImmediate;
    var canPost = typeof window !== 'undefined'
        && window.postMessage && window.addEventListener
    ;

    if (canSetImmediate) {
        return function (f) { return window.setImmediate(f) };
    }

    if (canPost) {
        var queue = [];
        window.addEventListener('message', function (ev) {
            if (ev.source === window && ev.data === 'browserify-tick') {
                ev.stopPropagation();
                if (queue.length > 0) {
                    var fn = queue.shift();
                    fn();
                }
            }
        }, true);

        return function nextTick(fn) {
            queue.push(fn);
            window.postMessage('browserify-tick', '*');
        };
    }

    return function nextTick(fn) {
        setTimeout(fn, 0);
    };
})();

process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];

process.binding = function (name) {
    if (name === 'evals') return (require)('vm')
    else throw new Error('No such module. (Possibly not yet loaded)')
};

(function () {
    var cwd = '/';
    var path;
    process.cwd = function () { return cwd };
    process.chdir = function (dir) {
        if (!path) path = require('path');
        cwd = path.resolve(dir, cwd);
    };
})();

});

require.define("/entities/land.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.4.0
(function() {
  var Land, Voxel, blankMat, div, lands, makeTree, mergedGeo, mesh, ratio, rough, roughQuad, size, turns, x, y;

  size = 1;

  div = 5;

  ratio = size / div;

  blankMat = new THREE.Material;

  Voxel = function() {
    return new THREE.Mesh(new THREE.CubeGeometry(ratio, ratio, ratio), blankMat);
  };

  lands = (function() {
    var _i, _j, _k, _results;
    _results = [];
    for (rough = _i = 0; _i <= 10; rough = ++_i) {
      mergedGeo = new THREE.Geometry();
      for (x = _j = 0; 0 <= div ? _j <= div : _j >= div; x = 0 <= div ? ++_j : --_j) {
        for (y = _k = 0; 0 <= div ? _k <= div : _k >= div; y = 0 <= div ? ++_k : --_k) {
          roughQuad = rough / 10;
          mesh = Voxel();
          mesh.position.x = x * ratio - size / 2;
          mesh.position.y = y * ratio - size / 2;
          mesh.position.z = Math.random() * roughQuad * ratio;
          THREE.GeometryUtils.merge(mergedGeo, mesh);
        }
      }
      _results.push(mergedGeo);
    }
    return _results;
  })();

  makeTree = function(num) {
    var thickness, wood, _i, _ref;
    mergedGeo = new THREE.Geometry();
    thickness = Math.max(1, Math.floor(num / 10));
    for (wood = _i = 0, _ref = num - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; wood = 0 <= _ref ? ++_i : --_i) {
      mesh = Voxel();
      mesh.position.x = (wood % thickness) * ratio - ratio + (Math.random() * ratio - ratio / 2) / 4;
      mesh.position.y = (Math.floor(wood / thickness) % thickness) * ratio - ratio + (Math.random() * ratio - ratio / 2) / 4;
      mesh.position.z = Math.floor(wood / (thickness * thickness)) * ratio;
      THREE.GeometryUtils.merge(mergedGeo, mesh);
    }
    return mergedGeo;
  };

  turns = [Math.PI, 0, Math.PI / 2, 3 * Math.PI / 2];

  Land = (function() {

    function Land(entity, scene) {
      this.scene = scene;
      this.properties = entity.properties;
      this.makeObj();
    }

    Land.prototype.makeObj = function() {
      var mat, _ref, _ref1;
      mat = new THREE.MeshLambertMaterial({
        color: this.computeColor()
      });
      switch (this.properties.type) {
        case "tree":
          return this.addObj(new THREE.Mesh(makeTree((_ref = this.properties.wood) != null ? _ref : 1), mat));
        default:
          mesh = new THREE.Mesh(lands[(_ref1 = this.properties.roughness) != null ? _ref1 : 10], mat);
          mesh.rotation.setZ(turns[Math.floor(Math.random() * 4)]);
          return this.addObj(mesh);
      }
    };

    Land.prototype.addObj = function(obj) {
      var props;
      this.obj = obj;
      props = this.properties;
      obj.position.x = props.x;
      obj.position.y = props.y;
      if (props.z > 0) {
        props.z -= .5;
      }
      obj.position.z = props.z + (Math.random() * .01);
      return this.scene.add(obj);
    };

    Land.prototype.removeObj = function() {
      return this.scene.remove(this.obj);
    };

    Land.prototype.update = function(_arg) {
      var properties, _ref;
      properties = _arg.properties;
      $.extend(this.properties, properties);
      if (properties.phosphorus || properties.nitrogen || properties.phosorphus) {
        if ((_ref = this.obj) != null) {
          _ref.material.color = this.computeColor();
        }
      }
      if (properties.wood != null) {
        this.removeObj();
        return this.makeObj();
      }
    };

    Land.prototype.kill = function() {
      this.scene.remove(this.obj);
      return this.obj.deallocate();
    };

    Land.prototype.computeColor = function() {
      var color, green;
      color = new THREE.Color(0x002600);
      green = this.properties.nitrogen / 100 * 1;
      green += this.properties.potassium / 100 * 1;
      green += this.properties.phosphorus / 100 * 1;
      color.g = Math.max(.41, green / 3);
      color.r = Math.max(0, .41 - green / 3);
      color.b = Math.max(0, .41 - green / 3);
      return color;
    };

    return Land;

  })();

  module.exports = Land;

}).call(this);

});

require.define("/app.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.4.0
(function() {
  var Controls, Land;

  Land = require("./entities/land");

  Controls = (function() {

    function Controls(camera, speed, grid) {
      var _this = this;
      this.camera = camera;
      this.speed = speed != null ? speed : 10;
      this.grid = grid != null ? grid : [];
      this.keyState = new THREEx.KeyboardState();
      this.mouse = new THREE.Vector2();
      this.projector = new THREE.Projector();
      this.curUpdate = 0;
      this.selected = void 0;
      this.lastPos = this.camera.position;
      $("body").mousemove(function(e) {
        var intersects, ray, vector;
        _this.mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
        _this.mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
        vector = new THREE.Vector3(_this.mouse.x, _this.mouse.y, 0.5);
        _this.projector.unprojectVector(vector, _this.camera);
        ray = new THREE.Ray(_this.camera.position, vector.subSelf(_this.camera.position).normalize());
        intersects = ray.intersectObjects(_this.grid);
        if (intersects.length > 0) {
          if (_this.selected !== intersects[0].object) {
            return _this.changeSelected(intersects[0].object);
          }
        }
      });
      $("body").mousewheel(function(e, delta, deltaX, deltaY) {
        var newLook;
        _this.camera.position.z += deltaY * 2;
        newLook = _this.camera.position.copy();
        newLook.y += 5;
        newLook.z -= 20;
        return _this.camera.lookAt(newLook);
      });
    }

    Controls.prototype.changeSelected = function(newSelected) {
      if (this.selected) {
        this.selected.material.color = this.selectedoldColor;
      }
      this.selected = newSelected;
      this.selectedoldColor = this.selected.material.color;
      return this.selected.material.color = new THREE.Color(0xFF0000);
    };

    Controls.prototype.updateRate = 100;

    Controls.prototype.moveUpdate = function(delta) {
      var pos, _ref;
      this.curUpdate += delta * 1000;
      if (this.curUpdate >= this.updateRate) {
        this.curUpdate = 0;
        pos = {
          x: this.camera.position.x,
          y: this.camera.position.y + 5,
          z: 0
        };
        return (_ref = this.socket) != null ? _ref.emit("update", pos) : void 0;
      }
    };

    Controls.prototype.update = function(delta) {
      this.moveUpdate(delta);
      if (this.keyState.pressed("w")) {
        this.camera.position.y += this.speed * delta;
      }
      if (this.keyState.pressed("s")) {
        this.camera.position.y -= this.speed * delta;
      }
      if (this.keyState.pressed("a")) {
        this.camera.position.x -= this.speed * delta;
      }
      if (this.keyState.pressed("d")) {
        return this.camera.position.x += this.speed * delta;
      }
    };

    return Controls;

  })();

  $(function() {
    var ASPECT, FAR, HEIGHT, NEAR, VIEW_ANGLE, WIDTH, camera, clock, controls, entities, fogged, light, render, renderer, scene, socket;
    WIDTH = window.innerWidth;
    HEIGHT = window.innerHeight;
    VIEW_ANGLE = 45;
    ASPECT = WIDTH / HEIGHT;
    NEAR = 0.1;
    FAR = 100000;
    renderer = new THREE.WebGLRenderer();
    renderer.shadowMapEnabled = true;
    renderer.setSize(WIDTH, HEIGHT);
    document.body.appendChild(renderer.domElement);
    clock = new THREE.Clock();
    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR);
    camera.position.set(0, -5, 20);
    camera.lookAt(scene.position);
    scene.add(camera);
    light = new THREE.PointLight(0xFFFFFF);
    light.position.set(0, 0, 0);
    camera.add(light);
    controls = new Controls(camera, 10, scene.children);
    render = function() {
      controls.update(clock.getDelta());
      renderer.render(scene, camera);
      return requestAnimationFrame(render);
    };
    socket = io.connect(null, {
      reconnect: false
    });
    controls.socket = socket;
    entities = {};
    fogged = [];
    socket.on("update", function(view) {
      var entity, id, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = view.length; _i < _len; _i++) {
        entity = view[_i];
        switch (entity.type) {
          case "fog":
            if (entities[entity.properties.id]) {
              entities[entity.properties.id].kill();
              entities[entity.properties.id] = void 0;
              _results.push(delete entities[entity.properties.id]);
            } else {
              _results.push(void 0);
            }
            break;
          default:
            id = entity.properties.id;
            if (!entities[id]) {
              _results.push(entities[id] = new Land(entity, scene));
            } else {
              _results.push(entities[id].update(entity));
            }
        }
      }
      return _results;
    });
    return render();
  });

}).call(this);

});
require("/app.js");
})();
