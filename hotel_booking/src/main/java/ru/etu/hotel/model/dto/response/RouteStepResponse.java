package ru.etu.hotel.model.dto.response;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data @Builder
public class RouteStepResponse {
    private Integer level;
    private Integer opId;
    private Integer parentOpId;
    private Integer productId;
    private String productName;
    private String kind;
    private Integer num;
    private String opName;
    private String opClass;
    private String workCenter;
    private String profession;
    private Integer qualification;
    private BigDecimal tpz;
    private BigDecimal tsht;
    private BigDecimal qtyPerProduct;
    private String unitName;
}
