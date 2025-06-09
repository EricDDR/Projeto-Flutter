package com.seuprojeto.repository;

import com.seuprojeto.models.PetCadastro;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface PetCadastroRepository extends MongoRepository<PetCadastro, String> {
    List<PetCadastro> findByNomeAnimalContainingIgnoreCase(String nomeAnimal);
}
