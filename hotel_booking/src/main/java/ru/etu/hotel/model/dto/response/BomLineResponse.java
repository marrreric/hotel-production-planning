package ru.etu.hotel.model.dto.response;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data @Builder
public class BomLineResponse {
    private Integer id;
    private Integer specId;
    private Integer position;
    private String action;
    private Integer excludedComponentId;
    private Integer componentId;
    private BigDecimal quantity;
    private Integer eiId;
    private LocalDate dateFrom;
    private LocalDate dateTo;
    private Integer noticeFromId;
    private Integer noticeToId;
}