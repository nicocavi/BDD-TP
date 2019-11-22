#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#      tcpserver.py
#
#      Copyright 2014 Recursos Python - www.recursospython.com
#
#
import fdb
import psycopg2
import pymysql
from socket import socket, error
from threading import Thread


class Client(Thread):
    """
    Servidor eco - reenvía todo lo recibido.
    """
    
    def __init__(self, conn, addr, conFdb, curFdb, conPsql, curPsql, conMy, curMy):
        # Inicializar clase padre.
        Thread.__init__(self)
        
        self.conn = conn
        self.addr = addr
        self.conFdb = conFdb
        self.curFdb = curFdb
        self.conPsql = conPsql
        self.curPsql = curPsql
        self.conMy = conMy
        self.curMy = curMy
    
    def run(self):

        while True:
            try:
                # Recibir datos del cliente.
                input_data = self.conn.recv(1024)
            except error:
                print("[%s] Error de lectura." % self.name)
                break
            else:
                # Reenviar la información recibida.
                if input_data:
                    #Procesar consulta del cliente
                    input_data = input_data.decode().lower()
                    consulta = input_data.split(" ",1)
                    print(consulta[0])
                    if(consulta[0] == "postgres"):
                        try:
                            self.curPsql.execute(consulta[1])
                            
                            if(input_data.split(" ",2)[1] == "select"):
                                
                                aux = ""
                                for elemento in self.curPsql.fetchall():
                                    for sub in elemento:
                                        aux += "|"+str(sub) 
                                    aux += "\n"
                                self.conn.send(aux.encode())
                            else:
                                self.conn.send(b"Consulta realizada correctamente.")      
                            self.conPsql.commit()
                        except (Exception, psycopg2.DatabaseError) as error:
                            print(error)
                            self.conn.send('{}'.format(error).encode())   
                            self.conPsql.rollback()

                    elif(str(consulta[0]) == "firebird"):
                        try:
                            self.curFdb.execute(consulta[1])
                            if(input_data.split(" ",2)[1] == "select"):
                                
                                aux = ""
                                for elemento in self.curFdb.fetchall():
                                    for sub in elemento:
                                        aux += "|"+str(sub) 
                                    aux += "\n"
                                self.conn.send(aux.encode())
                            else:
                                self.conn.send(b"Consulta realizada correctamente.")      
                            self.conFdb.commit()
                        except (Exception, fdb.DatabaseError) as error:
                            print(error)
                            self.conn.send('{}'.format(error).encode())   
                            self.conFdb.rollback()
                    elif(str(consulta[0]) == "mysql"):
                        try:
                            self.curFdb.execute(consulta[1])
                            if(input_data.split(" ",2)[1] == "select"):
                                
                                aux = ""
                                for elemento in self.curFdb.fetchall():
                                    for sub in elemento:
                                        aux += "|"+str(sub) 
                                    aux += "\n"
                                self.conn.send(aux.encode())
                            else:
                                self.conn.send(b"Consulta realizada correctamente.")      
                            self.conFdb.commit()
                        except (Exception, fdb.DatabaseError) as error:
                            print(error)
                            self.conn.send('{}'.format(error).encode())   
                            self.conFdb.rollback()
                    else:  
                        self.conn.send(b"Query incorrecta.")

def main():
    s = socket()
    
    # Escuchar peticiones en el puerto 6030.
    s.bind(("localhost", 6030))
    s.listen(10)

    #Conexion con Firebird
    conFdb = fdb.connect(dsn='/home/cavi/Escritorio/Universidad/Practica/BDII/clientes.fdb', user='sysdba', password='masterkey')
    print ('Conexion exitosa con Firebird')
    print ('Firebird version:',conFdb.version)
    print ('ODS version:',conFdb.ods)
    curFdb = conFdb.cursor()

    #Conexion con PostgreSQL
    conPsql = psycopg2.connect("dbname=facturas user=postgres password=nicolas")
    curPsql = conPsql.cursor()
    print ('Conexion exitosa con PostgreSQL')
    print ('PostgreSQL version:',conPsql.server_version)

    #Conexion con MySQL
    conMy = pymysql.connect("localhost","nicolas","nicolas","facturacion")
    curMy = conMy.cursor()
    print ('Conexion exitosa con MySQL')
    print ('MySQL version:',conMy.server_version)



    while True:
        conn, addr = s.accept()
        c = Client(conn, addr, conFdb, curFdb, conPsql, curPsql, conMy, curMy)
        c.start()
        print("%s:%d se ha conectado." % addr)
if __name__ == "__main__":
    main()