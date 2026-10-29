package ru.etu.hotel.model.dto.response;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

// результат calc_cost
@Data @Builder
public class RouteCostResponse {
    private Integer productId;
    private Double quantity;
    private BigDecimal materialCost;
    private BigDecimal laborCost;
    private BigDecimal totalCost;
}
