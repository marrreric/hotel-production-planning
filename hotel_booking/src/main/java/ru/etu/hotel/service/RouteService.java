package ru.etu.hotel.service;

import ru.etu.hotel.model.dto.request.RouteApplyTpRequest;
import ru.etu.hotel.model.dto.response.*;
import ru.etu.hotel.model.entity.RouteOperation;

import java.util.List;

public interface RouteService {

    // Чтение
    List<RouteOperation> getOperations(Integer productId);
    List<RouteStepResponse> findTm(Integer productId);

    // Расчеты
    List<RouteMaterialResponse> mrQ(Integer opId, Double quantity);
    List<RouteMaterialResponse> sumMr(Integer productId, Double quantity);
    List<RouteLaborResponse> trTo(Integer productId, Double quantity);
    RouteCostResponse calcCost(Integer productId, Double quantity);

    // Типовой ТП
    Integer applyTypicalProcess(Integer productId, RouteApplyTpRequest request);
}
