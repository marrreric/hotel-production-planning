package ru.etu.hotel.model.dto.request;

import lombok.Data;
import java.math.BigDecimal;
import java.util.Map;

// тело POST-запроса применения типового ТП
@Data
public class RouteApplyTpRequest {
    private Integer tpId;
    // id параметра типового ТП -> значение для изделия
    private Map<Integer, BigDecimal> paramValues;
}
