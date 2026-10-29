package ru.etu.hotel.model.dto.response;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data @Builder
public class BomExplodeResponse {
    private Integer level;
    private Integer parentId;
    private Integer componentId;
    private String componentName;
    private String categoryName;
    private BigDecimal qtyPerParent;
    private BigDecimal qtyPerProduct;
    private String unitName;
    private Boolean hasSpec;
    private List<Integer> path;
}