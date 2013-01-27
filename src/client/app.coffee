Land = require "./entities/land"

class Controls 
    constructor: (@camera, @speed = 10, @grid = []) ->
        @keyState = new THREEx.KeyboardState()
        @mouse = new THREE.Vector2()
        @projector = new THREE.Projector()
        @curUpdate = 0
        @selected = undefined
        @lastPos = @camera.position
        $("body").mousemove (e) =>
            @mouse.x = ( event.clientX / window.innerWidth ) * 2 - 1;
            @mouse.y = - ( event.clientY / window.innerHeight ) * 2 + 1;

            vector = new THREE.Vector3 @mouse.x, @mouse.y, 0.5 
            @projector.unprojectVector vector, @camera 

            ray = new THREE.Ray @camera.position, vector.subSelf(@camera.position).normalize() 

            intersects = ray.intersectObjects @grid
            if intersects.length > 0 
                if @selected != intersects[0].object
                    @changeSelected intersects[0].object

        $("body").mousewheel (e, delta, deltaX, deltaY) =>
            @camera.position.z += deltaY*2
            newLook = @camera.position.copy()
            newLook.y += 5
            newLook.z -= 20
            @camera.lookAt newLook 

    changeSelected: (newSelected) ->
        if @selected
            @selected.material.color = @selectedoldColor
        @selected = newSelected
        @selectedoldColor = @selected.material.color
        @selected.material.color = new THREE.Color 0xFF0000

    updateRate: 100
    moveUpdate: (delta) ->
        @curUpdate += delta*1000
        if @curUpdate >= @updateRate    
            @curUpdate = 0
            pos = {x:@camera.position.x, y: @camera.position.y+5, z: 0}
            @socket?.emit "update", pos

    update: (delta) ->
        @moveUpdate delta
        if @keyState.pressed "w"
            @camera.position.y += @speed*delta
        if @keyState.pressed "s"
            @camera.position.y -= @speed*delta
        if @keyState.pressed "a"
            @camera.position.x -= @speed*delta
        if @keyState.pressed "d"
            @camera.position.x += @speed*delta

$ ->
    WIDTH = window.innerWidth
    HEIGHT = window.innerHeight

    VIEW_ANGLE = 45
    ASPECT = WIDTH/HEIGHT
    NEAR = 0.1
    FAR = 100000

    renderer = new THREE.WebGLRenderer()
    renderer.shadowMapEnabled = true
    renderer.setSize WIDTH, HEIGHT
    document.body.appendChild renderer.domElement

    clock = new THREE.Clock()

    scene = new THREE.Scene()

    camera = new THREE.PerspectiveCamera VIEW_ANGLE, ASPECT, NEAR, FAR
    camera.position.set( 0, -5, 20)
    camera.lookAt scene.position
    scene.add camera
    light = new THREE.DirectionalLight 0xFFFFFF
    light.position.set 0, 0, 0
    light.castShadow = true
    camera.add light
    controls = new Controls camera, 10, scene.children

    render = -> 
        controls.update clock.getDelta() 
        renderer.render scene, camera
        requestAnimationFrame render 

    socket = io.connect null, 
        reconnect: false
    controls.socket = socket
    entities = {}
    fogged = []
    socket.on "update", (view) ->
        for entity in view
            switch entity.type
                when "fog"
                    if entities[entity.properties.id] 
                        entities[entity.properties.id].kill()
                        entities[entity.properties.id] = undefined
                        delete entities[entity.properties.id]
                        
                else 
                    # Create 1x1 Square @ location
                    id = entity.properties.id

                    if not entities[id]
                        entities[id] = new Land entity, scene
                    else 
                        entities[id].update entity

    render()