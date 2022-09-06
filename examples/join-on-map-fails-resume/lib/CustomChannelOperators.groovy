/**
 * Provide a collection of custom channel operators that go beyond the nextflow default.
 */
class CustomChannelOperators {

    /**
     * Join two channels by one or more keys from a map contained in each channel.
     *
     * The channel elements are assumed to be tuples whose size is at least two.
     * Typically, the maps to join by are in the first position of the tuples.
     * Please read https://www.nextflow.io/docs/latest/operator.html#join carefully.
     *
     * @param args A map of keyword arguments that is passed on to the nextflow join call.
     * @param left The left-hand side channel in the join.
     * @param right The right-hand side channel in the join.
     * @param key A string or list of strings providing the map keys to compare.
     * @param leftBy The position of the map in the left channel.
     * @param rightBy The position of the map in the right channel.
     * @return The joined channels with the map in the original position of the left channel,
     *      followed by all elements of the right channel except for the map.
     */
    public static Object joinOnKeys(
            Map joinArgs = [:],
            left,
            right,
            key,
            int leftBy = 0,
            int rightBy = 0
    ) {
        List keys = key instanceof List ? key : [ key ]

        // Extract desired keys from the left map, located at `leftBy`, and prepend them.
        def newLeft = left.map { it[leftBy].subMap(keys).values() + it }

        // Extract desired keys from the right map, located at `rightBy`, and prepend them.
        // Also drop the map itself from the right.
        def newRight = right.map {
            it[rightBy].subMap(keys).values() +
            it[0..<rightBy] +
            it[rightBy<..<it.size()]
        }

        // Set the positions to join on explicitly.
        joinArgs.by = 0..<keys.size()

        // Apply the join channel operator to the channels and finally drop the keys used for joining tuples.
        return newLeft.join(joinArgs, newRight).map { it[keys.size()..<it.size()] }
    }

}
