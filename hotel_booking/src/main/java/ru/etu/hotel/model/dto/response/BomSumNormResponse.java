package ru.etu.hotel.model.dto.response;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data @Builder
public class BomSumNormResponse {
    private Integer componentId;
    private String componentName;
    private String categoryName;
    private BigDecimal totalNorm;
    private String unitName;
}