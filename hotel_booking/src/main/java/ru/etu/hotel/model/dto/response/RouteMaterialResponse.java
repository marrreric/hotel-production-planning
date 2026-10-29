package ru.etu.hotel.model.dto.response;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

// строка mr_q / sum_mr (у них одинаковые колонки)
@Data @Builder
public class RouteMaterialResponse {
    private Integer materialId;
    private String materialName;
    private BigDecimal norm;
    private String unitName;
    private BigDecimal unitPrice;
    private BigDecimal cost;
}
