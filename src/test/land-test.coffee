vows = require "vows"
assert = require "assert"

Land = require "../server/classes/Land"

vows.describe("Land").addBatch
    "A Land":
        topic: new Land()
        "has nutrients": (land) ->
            assert.isNumber land.phosphorus
            assert.isNumber land.potassium
            assert.isNumber land.nitrogen
        "can eat":
            topic: (land) ->
                otherLand = new Land()
                otherLand.nitrogen = 0
                land.nitrogen = 5
                otherLand.on "feed", =>
                    @callback null, [land, otherLand]  
                land.emit "eat", "nitrogen", 5, otherLand
                return

            "has fed the other land": ([land, otherLand]) ->
                assert.equal land.nitrogen, 0
            "has eaten from land": ([land, otherLand]) ->
                assert.equal otherLand.nitrogen, 5
.export module