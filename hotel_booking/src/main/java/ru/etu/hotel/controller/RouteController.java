package ru.etu.hotel.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ru.etu.hotel.model.dto.request.RouteApplyTpRequest;
import ru.etu.hotel.model.dto.response.*;
import ru.etu.hotel.model.entity.RouteOperation;
import ru.etu.hotel.service.RouteService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/route")
@RequiredArgsConstructor
public class RouteController {

    private final RouteService routeService;

    //  ЧТЕНИЕ 

    @GetMapping("/products/{productId}/operations")
    public ResponseEntity<List<RouteOperation>> getOperations(@PathVariable Integer productId) {
        return ResponseEntity.ok(routeService.getOperations(productId));
    }

    @GetMapping("/products/{productId}/route")
    public ResponseEntity<List<RouteStepResponse>> findTm(@PathVariable Integer productId) {
        return ResponseEntity.ok(routeService.findTm(productId));
    }

    //  РАСЧЕТЫ 

    @GetMapping("/operations/{opId}/materials")
    public ResponseEntity<List<RouteMaterialResponse>> mrQ(
            @PathVariable Integer opId,
            @RequestParam(defaultValue = "1") Double quantity) {
        return ResponseEntity.ok(routeService.mrQ(opId, quantity));
    }

    @GetMapping("/products/{productId}/materials")
    public ResponseEntity<List<RouteMaterialResponse>> sumMr(
            @PathVariable Integer productId,
            @RequestParam(defaultValue = "1") Double quantity) {
        return ResponseEntity.ok(routeService.sumMr(productId, quantity));
    }

    @GetMapping("/products/{productId}/labor")
    public ResponseEntity<List<RouteLaborResponse>> trTo(
            @PathVariable Integer productId,
            @RequestParam(defaultValue = "1") Double quantity) {
        return ResponseEntity.ok(routeService.trTo(productId, quantity));
    }

    @GetMapping("/products/{productId}/cost")
    public ResponseEntity<RouteCostResponse> calcCost(
            @PathVariable Integer productId,
            @RequestParam(defaultValue = "1") Double quantity) {
        return ResponseEntity.ok(routeService.calcCost(productId, quantity));
    }

    //  ТИПОВОЙ ТП 

    @PostMapping("/products/{productId}/apply-tp")
    public ResponseEntity<Map<String, Integer>> applyTypicalProcess(
            @PathVariable Integer productId,
            @RequestBody RouteApplyTpRequest request) {
        Integer count = routeService.applyTypicalProcess(productId, request);
        return ResponseEntity.ok(Map.of("operationsCreated", count));
    }
}
