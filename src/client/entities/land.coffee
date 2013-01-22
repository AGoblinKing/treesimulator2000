size = 1
div = 5
ratio = size/div
geos = (for x in [0..5]
    mat = new THREE.Material
    mergedGeo = new THREE.Geometry()
    for x in [0..div]
        for y in [0..div]
            mesh = new THREE.Mesh new THREE.CubeGeometry(ratio, ratio, ratio), mat
            mesh.position.x = x*ratio
            mesh.position.y = y*ratio
            mesh.position.z = (Math.random())*ratio
            
            THREE.GeometryUtils.merge(mergedGeo, mesh)
    mergedGeo
)

class Land
    constructor: (entity, @scene) ->
        @properties = entity.properties

        mat = new THREE.MeshLambertMaterial
            color: @computeColor()

        @obj = obj = switch @properties.type
            when "tree"
                new THREE.Mesh new THREE.CubeGeometry(size, size, size), mat
            else
                new THREE.Mesh geos[Math.floor((Math.random()*5))], mat

        props = entity.properties
        obj.position.x = props.x
        obj.position.y = props.y
        if props.z > 0 
            props.z -= .5
        obj.position.z = props.z
        ###
        outline = new THREE.MeshLambertMaterial
            color: 0x000000
            wireframe: true
        outlineMesh = new THREE.Mesh geom, outline
        outlineMesh.position.z += .001
        obj.add outlineMesh
        ###
        @scene.add obj

    update: ({properties}) ->
        $.extend @properties, properties
        if properties.phosphorus or properties.nitrogen or properties.phosorphus
            @obj.material.color = @computeColor()  

    kill: ->
        @scene.remove @obj
        @obj.deallocate()

    computeColor: ->
        # green
        color = new THREE.Color 0x5E2605
        green = @properties.nitrogen/100 * 1
        # yellow
        green += @properties.potassium/100 * 1
        # brown
        green += @properties.phosphorus/100 * 1
        color.g = green/3
        color

module.exports = Land