package ru.etu.hotel.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.etu.hotel.model.dto.request.RouteApplyTpRequest;
import ru.etu.hotel.model.dto.response.*;
import ru.etu.hotel.model.entity.RouteOperation;
import ru.etu.hotel.repository.RouteOperationRepository;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class RouteServiceImpl implements RouteService {

    private final RouteOperationRepository routeRepository;

    //  ЧТЕНИЕ 

    @Override
    @Transactional(readOnly = true)
    public List<RouteOperation> getOperations(Integer productId) {
        return routeRepository.findByProductIdOrderByNumAsc(productId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<RouteStepResponse> findTm(Integer productId) {
        List<RouteStepResponse> result = new ArrayList<>();
        for (Object[] r : routeRepository.findTm(productId)) {
            result.add(RouteStepResponse.builder()
                    .level(toInt(r[0]))
                    .opId(toInt(r[1]))
                    .parentOpId(toInt(r[2]))
                    .productId(toInt(r[3]))
                    .productName((String) r[4])
                    .kind((String) r[5])
                    .num(toInt(r[6]))
                    .opName((String) r[7])
                    .opClass((String) r[8])
                    .workCenter((String) r[9])
                    .profession((String) r[10])
                    .qualification(toInt(r[11]))
                    .tpz(toBigDecimal(r[12]))
                    .tsht(toBigDecimal(r[13]))
                    .qtyPerProduct(toBigDecimal(r[14]))
                    .unitName((String) r[15])
                    .build());
        }
        return result;
    }

    //  РАСЧЕТЫ 

    @Override
    @Transactional(readOnly = true)
    public List<RouteMaterialResponse> mrQ(Integer opId, Double quantity) {
        return toMaterials(routeRepository.mrQ(opId, quantity));
    }

    @Override
    @Transactional(readOnly = true)
    public List<RouteMaterialResponse> sumMr(Integer productId, Double quantity) {
        return toMaterials(routeRepository.sumMr(productId, quantity));
    }

    @Override
    @Transactional(readOnly = true)
    public List<RouteLaborResponse> trTo(Integer productId, Double quantity) {
        List<RouteLaborResponse> result = new ArrayList<>();
        for (Object[] r : routeRepository.trTo(productId, quantity)) {
            result.add(RouteLaborResponse.builder()
                    .professionId(toInt(r[0]))
                    .profession((String) r[1])
                    .qualification(toInt(r[2]))
                    .totalMin(toBigDecimal(r[3]))
                    .totalHours(toBigDecimal(r[4]))
                    .hourlyRate(toBigDecimal(r[5]))
                    .cost(toBigDecimal(r[6]))
                    .build());
        }
        return result;
    }

    @Override
    @Transactional(readOnly = true)
    public RouteCostResponse calcCost(Integer productId, Double quantity) {
        Object[] r = routeRepository.calcCost(productId, quantity).get(0);
        return RouteCostResponse.builder()
                .productId(productId)
                .quantity(quantity)
                .materialCost(toBigDecimal(r[0]))
                .laborCost(toBigDecimal(r[1]))
                .totalCost(toBigDecimal(r[2]))
                .build();
    }

    //  ТИПОВОЙ ТП 
    /* сначала сохраняет значения параметров, потом вызывает SQL-функцию. 
    Всё это идёт в одной транзакции (@Transactional над классом). 
    Если функция упадёт, например не хватает параметра, то и сохранённые значения откатятся. 
    */
    @Override
    public Integer applyTypicalProcess(Integer productId, RouteApplyTpRequest request) {
        if (request.getParamValues() != null) {
            for (Map.Entry<Integer, BigDecimal> e : request.getParamValues().entrySet()) {
                routeRepository.setTpValue(productId, e.getKey(), e.getValue());
            }
        }
        Integer count = routeRepository.applyTypicalProcess(productId, request.getTpId());
        log.info("Applied typical process {} to product {}: {} operations",
                request.getTpId(), productId, count);
        return count;
    }

    // ВСПОМОГАТЕЛЬНЫЕ

    private List<RouteMaterialResponse> toMaterials(List<Object[]> rows) {
        List<RouteMaterialResponse> result = new ArrayList<>();
        for (Object[] r : rows) {
            result.add(RouteMaterialResponse.builder()
                    .materialId(toInt(r[0]))
                    .materialName((String) r[1])
                    .norm(toBigDecimal(r[2]))
                    .unitName((String) r[3])
                    .unitPrice(toBigDecimal(r[4]))
                    .cost(toBigDecimal(r[5]))
                    .build());
        }
        return result;
    }

    private Integer toInt(Object o) {
        if (o == null) return null;
        if (o instanceof Number n) return n.intValue();
        return null;
    }

    private BigDecimal toBigDecimal(Object o) {
        if (o == null) return null;
        if (o instanceof BigDecimal b) return b;
        if (o instanceof Number n) return BigDecimal.valueOf(n.doubleValue());
        return new BigDecimal(o.toString());
    }
}
