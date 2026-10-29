package ru.etu.hotel.model.dto.response;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

// строка tr_to
@Data @Builder
public class RouteLaborResponse {
    private Integer professionId;
    private String profession;
    private Integer qualification;
    private BigDecimal totalMin;
    private BigDecimal totalHours;
    private BigDecimal hourlyRate;
    private BigDecimal cost;
}
