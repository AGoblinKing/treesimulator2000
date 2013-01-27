size = 1
div = 5
ratio = size/div

blankMat = new THREE.Material

Voxel = ->
    new THREE.Mesh new THREE.CubeGeometry(ratio, ratio, ratio), blankMat

lands = (for rough in [0..10]
    mergedGeo = new THREE.Geometry()
    for x in [0..div]
        for y in [0..div]
            roughQuad = rough/10
            mesh = Voxel()
            mesh.position.x = x*ratio - size/2
            mesh.position.y = y*ratio - size/2
            mesh.position.z = Math.random()*roughQuad*ratio
            
            THREE.GeometryUtils.merge(mergedGeo, mesh)
    mergedGeo
)


makeTree = (num) ->
    # assume num is thenumber of wood
    mergedGeo = new THREE.Geometry()
    # TODO: add thickness
    thickness = Math.max 1, Math.floor num/10
    for wood in [0..num-1]
        mesh = Voxel()
        mesh.position.x = (wood % thickness)*ratio - ratio + (Math.random()*ratio - ratio/2)/4
        mesh.position.y = (Math.floor(wood/thickness) % thickness)*ratio - ratio + (Math.random()*ratio - ratio/2)/4
        mesh.position.z = Math.floor(wood/(thickness*thickness))*ratio
        THREE.GeometryUtils.merge(mergedGeo, mesh)
    mergedGeo


turns = [Math.PI, 0, Math.PI/2, 3*Math.PI/2]
class Land
    constructor: (entity, @scene) ->
        @properties = entity.properties
        @makeObj()

    makeObj: () ->
        mat = new THREE.MeshLambertMaterial
            color: @computeColor()

        switch @properties.type
            when "tree"
                @addObj new THREE.Mesh makeTree(@properties.wood ? 1), mat
            else
                mesh = new THREE.Mesh lands[@properties.roughness ? 10], mat
                mesh.rotation.setZ turns[Math.floor Math.random()*4]
                @addObj mesh 

    addObj: (obj) ->
        @obj = obj
        props = @properties
        obj.position.x = props.x
        obj.position.y = props.y
        if props.z > 0 
            props.z -= .5
        obj.position.z = props.z+(Math.random()*.01)
        @scene.add obj

    removeObj: () ->
        @scene.remove @obj

    update: ({properties}) ->
        $.extend @properties, properties
        if properties.phosphorus or properties.nitrogen or properties.phosorphus
            @obj?.material.color = @computeColor()  

        if properties.wood?
            @removeObj()
            @makeObj()

    kill: ->
        @scene.remove @obj
        @obj.deallocate()

    computeColor: ->
        # green
        color = new THREE.Color 0x002600
        green = @properties.nitrogen/100 * 1
        # yellow
        green += @properties.potassium/100 * 1
        # brown
        green += @properties.phosphorus/100 * 1
        color.g = Math.max .41, green/3
        color.r = Math.max 0, .41 - green/3
        color.b = Math.max 0, .41 - green/3
        color

module.exports = Land