using LabDefontana.ViewModels;

namespace LabDefontana.Services.Interfaces
{
    public interface IVentasService
    {
        Task<VentaViewModel> ConsultaDetalleVentas();
    }
}
