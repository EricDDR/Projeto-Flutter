package com.seuprojeto.models;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "pets")
public class PetCadastro {

    @Id
    private String id;
    private String nomeAnimal;
    private String raca;
    private String numeroDono;
}
