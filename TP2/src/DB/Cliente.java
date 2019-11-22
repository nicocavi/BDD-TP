package DB;

public class Cliente {
	
	private int id;
	private String descripcion;
	private static int cont;
	
	public Cliente(int id, String descripcion) {
		this.id = id;
		this.descripcion = descripcion;
	}

	public int getId() {
		return id;
	}

	public String getDescripcion() {
		return descripcion;
	}

	public void setDescripcion(String descripcion) {
		this.descripcion = descripcion;
	}
	
	public String getString() {
		return this.id+" | "+ this.descripcion+" |";
	}
	
}
