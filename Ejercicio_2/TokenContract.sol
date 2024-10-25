// SPDX-License-Identifier: Unlicenced
pragma solidity ^0.8.18;

import "hardhat/console.sol";

contract TokenContract {

    address public owner;
    uint256 public tokenPrice = 5 ether;  // Precio por token: 5 Ether
    uint256 public contractBalance;       // Almacena el balance del contrato en Ether

    struct Receivers {
        string name;
        uint256 tokens;
    }
    mapping(address => Receivers) public users;

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    constructor(){
        owner = msg.sender;
        users[owner].tokens = 100;
    }

    function double(uint _value) public pure returns (uint){
        return _value*2;
    }

    function register(string memory _name) public{
        users[msg.sender].name = _name;
    }

    function giveToken(address _receiver, uint256 _amount) onlyOwner public{
        require(users[owner].tokens >= _amount);
        users[owner].tokens -= _amount;
        users[_receiver].tokens += _amount;
    }

    // function buyTokens(address _owner, uint256 _amount) onlyOwner public{
    //     require(users[owner].tokens >= _amount);
    //     users[owner].tokens -= _amount;
    //     users[_receiver].tokens += _amount;
    // }


    // Comprar tantos tokens como el Ether enviado permita
    function buyTokens() public payable {
        require(msg.value > 0, "Debes enviar Ether para comprar tokens");
        require(msg.value > tokenPrice, "El Ether enviado no es suficiente para comprar tokens");

        // Calcular cuántos tokens puede comprar el usuario con el Ether enviado
        uint256 numTokensToBuy = msg.value / tokenPrice;

        // Verificar si el propietario tiene suficientes tokens
        uint256 tokensAvailable = users[owner].tokens;
        require(tokensAvailable > 0, "El propietario no tiene tokens disponibles para vender");

        // Si el propietario no tiene suficientes tokens, comprar solo los que tenga
        if (numTokensToBuy > tokensAvailable) {
            numTokensToBuy = tokensAvailable;
        }

        // Calcular el costo real en Ether por los tokens comprados
        uint256 cost = numTokensToBuy * tokenPrice;

        // Transferir los tokens al comprador
        users[owner].tokens -= numTokensToBuy;
        users[msg.sender].tokens += numTokensToBuy;

        // Registrar el balance de Ether recibido
        contractBalance += cost;

        // Si enviaron más Ether de lo necesario, devolver la diferencia
        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
    }

    // Ver el balance en Ether del contrato
    function getContractBalance() public view returns (uint256) {
        return contractBalance;
        
    }

    // El propietario puede retirar Ether del contrato
    function withdraw() public onlyOwner {
        require(contractBalance > 0, "No hay Ether disponible para retirar");
        payable(owner).transfer(contractBalance);
        contractBalance = 0;
    }

    // Recibe Ether cuando alguien envía directamente sin llamar a una función
    receive() external payable {
        contractBalance += msg.value;
    }
}