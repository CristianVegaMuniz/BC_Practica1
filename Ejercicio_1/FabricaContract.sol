//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.10;

contract FabricaContract {
    
    uint idDigits = 16;
    uint idModulus = 10 ** idDigits;
    Producto[] public productos;

    event ProductoNuevo(uint ArrayProductoId, string nombre, uint id);

    mapping (address => uint) public propietarioProductos;
    mapping (uint => address) public productoAPropietario;

    struct Producto {
        uint id;    
        string nombre;

    }

    function _crearProducto(uint _id, string memory _nombre) public {
        Producto memory producto = Producto(_id, _nombre);
        productos.push(producto);
        uint productoId = productos.length - 1;
        emit ProductoNuevo(productoId, _nombre, _id);
    }

    function crearProductoAleatorio(string memory _nombre) public {
        uint randId = _generarIdAleatorio(_nombre);
        _crearProducto(randId, _nombre);

    }

    function _generarIdAleatorio(string memory _str) view public returns (uint) {
       uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % idModulus;
    }

    function Propiedad(uint _productoId) public {
        require(productoAPropietario[_productoId] == address(0), "El producto ya tiene propietario");
        productoAPropietario[_productoId] = msg.sender;
        propietarioProductos[msg.sender]++;
    }

    function getProductosPorPropietario(address _propietario) view external returns (uint[] memory){
        uint contador = 0;
        uint[] memory resultado = new uint[](propietarioProductos[_propietario]);

        for (uint i = 0; i < productos.length; i++) {
            if (productoAPropietario[i] == _propietario) {
                resultado[contador] = i;
                contador++;
            }
        }

        return resultado;
    }
}