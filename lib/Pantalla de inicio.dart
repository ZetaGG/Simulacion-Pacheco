import 'package:flutter/material.dart';

class PantallaInicio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Algoritmos de Simulacion'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Tema 1'),
              onTap: () {
                Navigator.pushNamed(context, '/Tema1');
                            },
            ),
            ListTile(
              title: Text('Tema 2'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Aviso'),
                      content: Text('Contenido no disponible'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Aceptar'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: Text('Tema 3'),
              onTap: () {
                Navigator.pushNamed(context, '/PruebasEstadisticas');
              },
            ),
          ],
        ),
      ),
    );
  }
}