// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract CryptoContract {  

    uint256 public taxa = 100; // taxa fixa em wei
    uint256 public nextId = 0;

    // --- Sub-structs para reduzir stack ---
    struct DadosBasicos {
        string titulo;
        string tipo;
        string localidade; // obrigatório
        string processo;   // obrigatório
        string dataAssinatura; // obrigatório
        string descricao;  // obrigatório
    }

    struct DadosFinanceiros {
        uint256 valorContrato; // obrigatório
        string item;           // obrigatório
        uint256 qtde;          // obrigatório
        uint256 valorItem;     // obrigatório
    }

    // --- Struct principal ---
    struct ContratoAcqua {
        address fornecedor; // obrigatório
        DadosBasicos basicos;
        DadosFinanceiros financeiros;
        uint256 saldo;
        bool ativo;
    }

    // Mapeamento ID → Contrato
    mapping(uint256 => ContratoAcqua) public contratos;

    // --- Criar contrato ---
    function addContractAcqua(
        DadosBasicos calldata basicos,
        DadosFinanceiros calldata financeiros
    ) public {
        nextId++;
        ContratoAcqua storage novo = contratos[nextId];
        novo.fornecedor = msg.sender;
        novo.basicos = basicos;
        novo.financeiros = financeiros;
        novo.saldo = 0;
        novo.ativo = true;
    }

    // --- Atribuir valor (similar ao donate) ---
    function atribVal(uint256 id) public payable {
        require(msg.value > 0, "Valor deve ser > 0");
        require(contratos[id].ativo == true, "Contrato inativo");

        contratos[id].saldo += msg.value;
    }

    // --- Resgatar valor (similar ao withdraw) ---
    function getVal(uint256 id) public {
        ContratoAcqua storage contrato = contratos[id];
        require(contrato.fornecedor == msg.sender, "Sem permissao");
        require(contrato.ativo == true, "Contrato encerrado");
        require(contrato.saldo > taxa, "Saldo insuficiente");

        address payable destinatario = payable(contrato.fornecedor);
        destinatario.transfer(contrato.saldo - taxa);

        contrato.ativo = false;
    }
}
