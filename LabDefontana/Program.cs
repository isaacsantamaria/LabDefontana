using LabDefontana.Data;
using LabDefontana.Models;
using LabDefontana.Repository;
using LabDefontana.Repository.Interfaces;
using LabDefontana.Services;
using LabDefontana.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Win32;

var host = CreateHostBuilder(args).Build();

// Inicializaciones antes de ejecutar la apliación

using (var scope = host.Services.CreateScope())
{
    var services = scope.ServiceProvider;

    // Invocación de los métodos que realizan las operaciones de consultas
    var ventaService = services.GetRequiredService<IVentasService>();
    
    var venta = await ventaService.ConsultaDetalleVentas();

    Console.WriteLine("*********************************************");
    Console.WriteLine("************ INFORME DE VENTAS **************");
    Console.WriteLine("*********************************************");
    Console.WriteLine($"Monto Total en Ventas: {venta.TotalVentas:D}");
    Console.WriteLine($"Cantidad Total en Ventas: {venta.CantidadVentas:D}");
    Console.WriteLine($"Promedio Total en Ventas: {venta.PromedioVentas:D}");
    Console.WriteLine($"Monto de Mayor Venta: {venta.MontoVentaMayor:D}");
    Console.WriteLine($"Fecha de Mayor Venta: {venta.FechaVentaMayor:d}");
    Console.WriteLine($"Producto con mayor monto vendido: {venta.ProductoMasVendido}");
    Console.WriteLine($"Monto del Producto con mayor monto vendido: {venta.MontoProductoMasVendido}");
    Console.WriteLine($"Cantidad del Producto con mayor monto vendido: {venta.CantidadProductoMasVendido}");
    Console.WriteLine($"Local de Mayor Venta: {venta.LocalMayorVenta}");
    Console.WriteLine($"Monto Vendido del Local de Mayor Venta: {venta.MontoLocalMayorVenta}");
    Console.WriteLine($"Marca de Mayor Ganancia: {venta.MarcaMayorGanancia}");
    Console.WriteLine($"Monto de Ganancia de Marca de Mayor Ganancia: {venta.MontoMarcaMayorGanancia}");
    Console.WriteLine("Productos más Vendidos por Local:");
    Console.WriteLine("Codigo del Local|Nombre del Local|Codigo del Producto|Nombre del Producto|Total Vendido");

    foreach (var productoMasVendido in venta.ProductosMasVendidos)
    {
        Console.WriteLine($"{productoMasVendido.CodigoLocal}|{productoMasVendido.NombreLocal}|{productoMasVendido.CodigoProducto}|{productoMasVendido.NombreProducto}|{productoMasVendido.TotalVendido}");
    }
}

host.Run();

static IHostBuilder CreateHostBuilder(string[] args)
{
    return Host.CreateDefaultBuilder(args)
        .ConfigureAppConfiguration((hostContext, config) =>
        {
            config.SetBasePath(Environment.CurrentDirectory);
            config.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
        })
        .ConfigureServices((hostContext, services) =>
        {
            // En esta sección se puede colocar las configuraciones del contexto de datos.
            services.AddDbContext<ApplicationDbContext>(options =>
            {
                var configuration = hostContext.Configuration;
                var connectionString = configuration.GetConnectionString("DefaultContext");
                options.UseSqlServer(connectionString);
            });

            // Registro al inyector de dependencias de las clases que tendrán las reglas de negocio y datos
            services.AddScoped<IVentaRepository, VentaRepository>();
            services.AddScoped<IVentasService, VentasService>();
        });
}