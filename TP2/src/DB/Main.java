package DB;

import java.util.ArrayList;
import java.util.Scanner;

import com.db4o.Db4oEmbedded;
import com.db4o.ObjectContainer;


public class Main {
	
	private static Scanner sc = new Scanner(System.in);
	private static int op1, op2;
	private static ObjectContainer db = Db4oEmbedded.openFile(Db4oEmbedded.newConfiguration(),"facturacion.db4o");
	
	private static void menu() {
		System.out.println("Seleccione una opcion (1,2,3):");
		System.out.println("1) Factura");
		System.out.println("2) Cliente");
		System.out.println("3) Salir");
	}
	
	private static void crud() {
		System.out.println("Seleccione una operacion (1,2,3,4):");
		System.out.println("1) Insert");
		System.out.println("2) Select");
		System.out.println("3) Update");
		System.out.println("4) Delete");
	}
	
	
	//CRUD FACTURAS
	
	private static void insertFactura() {
		int id;
		float importe;
		System.out.println("Ingrese id cliente:");
		id = sc.nextInt();
		System.out.println("Ingrese importe del cliente: ");
		importe = sc.nextFloat();
		Metodos.addFactura(db, id, importe);
		
	}
	
	private static void selectFactura() {
		int op;
		
		System.out.println("Seleccione una opcion:");
		System.out.println("1) Listar todas las facturas");
		System.out.println("2) Seleccionar por numero de factura");
		op = sc.nextInt();
		
		if(op == 1) {
			ArrayList<Factura> lf = Metodos.selectFactura(db);
			for(Factura f : lf) System.out.println(f.getString());
		}else if(op == 2) {
			System.out.println("Ingrese numero de factura: ");
			op = sc.nextInt();
			Factura f = Metodos.selectFactura(db, op);
			System.out.println(f.getString());
		}
		
		
	}
	
	private static void deleteFactura() {
		int op;
		System.out.println("Ingrese numero de factura: ");
		op = sc.nextInt();
		Metodos.deleteFactura(db,op);
	}
	
	private static void updateFactura() {
		int nro;
		int id;
		float importe;
		System.out.println("Ingrese numero de factura: ");
		nro = sc.nextInt();
		System.out.println("Ingrese id del cliente: ");
		id = sc.nextInt();
		System.out.println("Ingrese importe del cliente: ");
		importe = sc.nextInt();
		Metodos.updateFactura(db,id, nro, importe);
	}
	
	//CRUD CLIENTE
	
	private static void insertCliente() {
		String descr;
		System.out.println("Ingrese descripcion del cliente:");
		descr = sc.nextLine();
		Metodos.addCliente(db, descr);
	}
	
	private static void selectCliente() {
		int op;
		
		System.out.println("Seleccione una opcion:");
		System.out.println("1) Listar todos los clientes");
		System.out.println("2) Seleccionar por id");
		op = sc.nextInt();
		
		if(op == 1) {
			ArrayList<Cliente> lc = Metodos.selectCliente(db);
			for(Cliente c : lc) System.out.println(c.getString());
		}else if(op == 2) {
			System.out.println("Ingrese numero de factura: ");
			op = sc.nextInt();
			Cliente c = Metodos.selectCliente(db, op);
			System.out.println(c.getString());
		}
		
		
	}
	
	private static void deleteCliente() {
		int op;
		System.out.println("Ingrese id del cliente: ");
		op = sc.nextInt();
		Metodos.deleteCliente(db,op);
	}
	
	private static void updateCliente() {
		int id;
		String descripcion;
		System.out.println("Ingrese id del cliente: ");
		id = sc.nextInt();
		System.out.println("Ingrese descripcion del cliente: ");
		descripcion = sc.nextLine();
		Metodos.updateCliente(db,id, descripcion);
	}
	
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		
		Metodos.Open(db);
		
		
		menu();
		op1 = sc.nextInt();
		while(op1 != 3) {
			crud();
			op2 = sc.nextInt();
			
			if(op1 == 1)  {
				
				if(op2 == 1) {					
					insertFactura();
				}else if(op2 == 2) {
					selectFactura();
				}else if(op2 == 3) {
					updateFactura();
				}else if(op2 == 4) {
					deleteFactura();
				}
				
			}else if(op1 == 2){
				if(op2 == 1) {					
					insertCliente();
				}else if(op2 == 2) {
					selectCliente();
				}else if(op2 == 3) {
					updateCliente();
				}else if(op2 == 4) {
					deleteCliente();
				}
			}
			menu();
			op1 = sc.nextInt();
		}
		
	}

}
