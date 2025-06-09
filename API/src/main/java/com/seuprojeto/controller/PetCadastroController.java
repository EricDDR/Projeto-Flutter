
package com.seuprojeto.controller;

import com.seuprojeto.models.PetCadastro;
import com.seuprojeto.repository.PetCadastroRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/petcadastro")
@CrossOrigin(origins = "*")
public class PetCadastroController {

    private final PetCadastroRepository repository;

    @PostMapping
    public ResponseEntity<?> createPet(@RequestBody PetCadastro pet) {
        PetCadastro savedPet = repository.save(pet);
        return ResponseEntity.ok(savedPet);
    }

    @GetMapping
    public ResponseEntity<?> getAllPets(@RequestParam(required = false) String nome) {
        List<PetCadastro> pets = (nome == null) ?
                repository.findAll() :
                repository.findByNomeAnimalContainingIgnoreCase(nome);
        return ResponseEntity.ok(pets);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updatePet(@PathVariable String id, @RequestBody PetCadastro pet) {
        return repository.findById(id)
                .map(existing -> {
                    existing.setNomeAnimal(pet.getNomeAnimal());
                    existing.setRaca(pet.getRaca());
                    existing.setNumeroDono(pet.getNumeroDono());
                    return ResponseEntity.ok(repository.save(existing));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePet(@PathVariable String id) {
        if (!repository.existsById(id)) return ResponseEntity.notFound().build();
        repository.deleteById(id);
        return ResponseEntity.ok().build();
    }

}
