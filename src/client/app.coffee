requirejs.config 
    paths: 
        "underscore": "//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.4/underscore-min"
        "threejs": "//cdnjs.cloudflare.com/ajax/libs/three.js/r55/three.min"
        "backbone": "//cdnjs.cloudflare.com/ajax/libs/backbone.js/0.9.10/backbone-min"
        "jquery": "//cdnjs.cloudflare.com/ajax/libs/jquery/1.9.1/jquery.min"
        "jquery-mousewheel": "//cdnjs.cloudflare.com/ajax/libs/jquery-mousewheel/3.0.6/jquery.mousewheel.min"
        "bootstrap": "//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.0/js/bootstrap.min"
    
    shim: 
        "jquery-mousewheel":
            deps: ["jquery"]
        "threejs": 
            exports: "THREE"
        "backbone": 
            deps: ["jquery", "underscore"]
            exports: "Backbone"
        "underscore":
            exports: "_"
        "jquery":
            exports: "$"

define ["scenes/game"], (IntroScene) ->