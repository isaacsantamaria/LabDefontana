namespace LabDefontana.ViewModels
{
    public class VentaViewModel
    {
        public int TotalVentas { get; set; }
        public int PromedioVentas  { get; set; }
        public int CantidadVentas { get; set; }
        public DateTime FechaVentaMayor { get; set; }
        public int MontoVentaMayor { get; set; }
        public string ProductoMasVendido { get; set; }
        public int MontoProductoMasVendido { get; set; }
        public int CantidadProductoMasVendido { get; set; }
        public string LocalMayorVenta { get; set; }
        public int MontoLocalMayorVenta { get; set; }
        public string MarcaMayorGanancia { get; set; }
        public int MontoMarcaMayorGanancia { get; set; }
        public List<ProductoMasVendidoViewModel> ProductosMasVendidos { get; set; }
    }
}
