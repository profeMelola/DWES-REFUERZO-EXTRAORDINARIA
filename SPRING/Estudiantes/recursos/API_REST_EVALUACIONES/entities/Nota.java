@Entity
public class Nota {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nia; // Número de Identificación del Alumno. No existe la entidad alumno, solo su NIA

    @ManyToOne
    @JoinColumn(name = "evaluacion_id", nullable = false)
    private Evaluacion evaluacion;

    private Integer calificacion; // Calificación sin decimales
}
