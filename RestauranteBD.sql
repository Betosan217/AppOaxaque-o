CREATE DATABASE RestauranteDB;
GO
USE RestauranteDB;
GO

-- Tabla de Usuarios del sistema (meseros, administradores, etc.)
CREATE TABLE Usuarios (
    IdUsuario INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Usuario NVARCHAR(50) NOT NULL UNIQUE,
    Clave NVARCHAR(100) NOT NULL,
    Rol NVARCHAR(50) NOT NULL CHECK (Rol IN ('Administrador', 'Mesero')),
    FechaCreacion DATETIME DEFAULT GETDATE(),
    Activo BIT DEFAULT 1
);

-- Tabla de Clientes
CREATE TABLE Clientes (
    IdCliente INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    FechaRegistro DATETIME DEFAULT GETDATE()
);
CREATE TABLE Mesas (
    IdMesa INT PRIMARY KEY IDENTITY(1,1),
    NoMesa INT NOT NULL UNIQUE,
    Capacidad INT DEFAULT 4,    -- Opcional: capacidad de personas
    Estado NVARCHAR(20) DEFAULT 'Disponible' CHECK (Estado IN ('Disponible', 'Ocupada'))
);
-- Tabla del Menú (productos que se venden)
CREATE TABLE Menu (
    IdMenu INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL CHECK (Precio > 0),
    Categoria NVARCHAR(50) CHECK (Categoria IN ('Tacos', 'Especialidades', 'Platillos')),
    Disponible BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

-- Tabla de Pedidos
CREATE TABLE Pedidos (
    IdPedido INT PRIMARY KEY IDENTITY(1,1),
    Fecha DATETIME DEFAULT GETDATE(),
    IdCliente INT FOREIGN KEY REFERENCES Clientes(IdCliente),
    IdUsuario INT FOREIGN KEY REFERENCES Usuarios(IdUsuario),
    Estado NVARCHAR(50) DEFAULT 'Pendiente' CHECK (Estado IN ('Pendiente', 'En Preparacion', 'Listo', 'Finalizado', 'Cancelado')),
    Total DECIMAL(10,2) DEFAULT 0,
    IdMesa INT NOT NULL,
    Observaciones NVARCHAR(500)
	FOREIGN KEY (IdMesa) REFERENCES Mesas(IdMesa)
);

-- Tabla intermedia PedidoMenu (relación muchos a muchos)
CREATE TABLE PedidoMenu (
    IdPedidoMenu INT PRIMARY KEY IDENTITY(1,1),
    IdPedido INT FOREIGN KEY REFERENCES Pedidos(IdPedido) ON DELETE CASCADE,
    IdMenu INT FOREIGN KEY REFERENCES Menu(IdMenu),
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    Subtotal AS (Cantidad * PrecioUnitario) PERSISTED
);


-- Índices para mejorar el rendimiento
CREATE INDEX IX_Pedidos_Fecha ON Pedidos(Fecha);
CREATE INDEX IX_Pedidos_Estado ON Pedidos(Estado);
CREATE INDEX IX_PedidoMenu_IdPedido ON PedidoMenu(IdPedido);




-- Tacos
INSERT INTO Menu (Nombre, Precio, Categoria) VALUES 
('Al Pastor', 18.00, 'Tacos'),
('Bisteck', 21.00, 'Tacos'),
('Choriso', 18.00, 'Tacos'),
('Chuleta', 21.00, 'Tacos');

-- Platillos
INSERT INTO Menu (Nombre, Precio, Categoria) VALUES 
('Pastor con Queso', 30.00, 'Platillos'),
('Bisteck con Queso', 30.00, 'Platillos'),
('Chuleta con Queso', 30.00, 'Platillos'),
('Choriso con Queso', 30.00, 'Platillos'),
('Que me ves', 18.00, 'Platillos'),
('Gringa', 18.00, 'Platillos'),
('Carnita', 30.00, 'Platillos'),
('Sincronizada', 15.00, 'Platillos'),
('Quesadilla', 13.00, 'Platillos'),
('Torta', 15.00, 'Platillos');

-- Especialidades
INSERT INTO Menu (Nombre, Precio, Categoria) VALUES 
('Fortachon', 40.00, 'Especialidades'),
('Alambre', 40.00, 'Especialidades'),
('Mixto', 40.00, 'Especialidades'),
('Tlaconete', 40.00, 'Especialidades'),
('Doble Mexicano', 40.00, 'Especialidades'),
('Carboncito', 40.00, 'Especialidades'),
('Soop Suey', 40.00, 'Especialidades'),
('Champiñon', 40.00, 'Especialidades'),
('Pingüino', 40.00, 'Especialidades');

INSERT INTO Mesas (NoMesa, Capacidad) VALUES 
(1, 4), (2, 4), (3, 4), (4, 4), (5, 4),
(6, 4), (7, 4), (8, 4), (9, 4), (10, 4),
(11, 4), (12, 4), (13, 4), (14, 4), (15, 4);

INSERT INTO Usuarios (Nombre, Usuario, Clave, Rol) 
VALUES ('Administrador', 'Admin', 'Admin123', 'Administrador');

SELECT * FROM Clientes;
INSERT INTO Clientes (Nombre, Telefono) VALUES ('Consumidor Final c/f','12345678');


SELECT * FROM Pedidos;

-- Verificar los valores exactos permitidos en el constraint
SELECT 
    cc.name AS constraint_name,
    cc.definition AS constraint_definition,
    t.name AS table_name,
    col.name AS column_name
FROM sys.check_constraints cc
INNER JOIN sys.tables t ON cc.parent_object_id = t.object_id
INNER JOIN sys.columns col ON cc.parent_object_id = col.object_id
WHERE t.name = 'Pedidos' AND col.name = 'Estado';