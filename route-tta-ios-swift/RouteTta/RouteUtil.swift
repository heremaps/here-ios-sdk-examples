/*
 * Copyright (c) 2011-2018 HERE Europe B.V.
 * All rights reserved.
 */

import Foundation
import NMAKit

typealias RouteContainer = (plan: [NMAGeoCoordinates], mode: NMARoutingMode)

func createRoute() -> RouteContainer {
    
    /* Define waypoints for the route */
    /* START: Holländerstraße, Wedding, 13407 Berlin */
    let startPoint = NMAGeoCoordinates(latitude: 52.562755700200796, longitude: 13.34599438123405)
    
    /* MIDDLE: Lynarstraße 3 */
    let middlePoint = NMAGeoCoordinates(latitude: 52.54172, longitude: 13.36354)
    
    /* END: Agricolastraße 29, 10555 Berlin */
    let endPoint = NMAGeoCoordinates(latitude: 52.520720371976495, longitude: 13.332345457747579)
    
    /* Initialize a RoutePlan */
    let routePlan = [startPoint, middlePoint, endPoint]
    
    /*
     * Initialize a RouteOption.HERE SDK allow users to define their own parameters for the
     * route calculation,including transport modes,route types and route restrictions etc.Please
     * refer to API doc for full list of APIs
     */
    
    let routeMode = NMARoutingMode()
    /* Other transport modes are also available e.g Pedestrian */
    routeMode.transportMode = NMATransportMode.car
    /* Disable highway in this route. */
    routeMode.routingOptions.insert(NMARoutingOption.avoidHighway)
    /* Calculate the shortest route available. */
    routeMode.routingType = NMARoutingType.fastest
    /* Calculate 1 route. */
    routeMode.resultLimit = 1

    return (plan: routePlan, mode: routeMode)
}
