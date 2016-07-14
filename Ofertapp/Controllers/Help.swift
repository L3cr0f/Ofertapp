//
//  Help.swift
//  Ofertapp
//
//  Created by Ernesto Fdez on 3/5/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit

class Help : UIViewController {
    
    @IBOutlet weak var helpTextView: UITextView!
    
    override func viewDidLoad() {
        helpTextView.text = "Ofertapp es tu aplicación de búsqueda de promociones. " +
            "En la pestaña \"Mapa\" de la ventana principal puede observar las distintas ofertas en su " +
            "ubicación, de manera que presionando con el dedo en una de estas podrás ver de que oferta " +
            "se trata (el botón superior derecho sirve para actualizar las ofertas presentes en el mapa. " +
            "En el caso de situarse en la pestaña \"Ofertas\" le aparecerá un listado con las " +
            "diversas ofertas (el tick verde indica que es una oferta creada por una empresa verificada) " +
            "de su zona ordenadas segun la fecha más próxima. Además, podrá buscar ofertas en función de " +
            "su nombre o su categoría, tan solo ha de presionar en la barra de búsqueda y el teclado se " +
            "desplegará. Al seleccionar una podrá ver más detallademente sus características. Para actualizar " +
            "las ofertas presentes en la lista tan solo tendrá que arrastrarla hacia abajo y soltar. " +
            "Si preisonas en el botón situado en la zona superior izquierda apreciaras como se despliega" +
            "un menú con diversas opciones. Si seleccionamos \"Crear Oferta\" iremos a una pantalla en la " +
            "que podremos realizar la creación de una oferta, pudiendo indicar o no la úbicación de la " +
            "promoción en cuestión, para ello tendremos que mantener presionado el dedo en la ubicación " +
            "deseada. En el caso de seleccionar la opción \"Ajustes\" del menú lateral te dirigirá " +
            "al menu de configuración de la cuenta (cabe destacar que el nickname ha de ser único, " +
            "al igual que el email y que la contraseña ha de tener al menos 6 caracteres) , para " +
            "la opción \"Ayuda\" de dicho menú nos dirigirá " +
            "a la pantalla que actualmente estás visualizando. Mencionar que en las pantallas de edición/" +
            "creación el boton \"Cerrar\" cierra directamente la pantalla, mientras que el botón \"Cancelar\" " +
            "en el caso de que hayas introducido algunos valores te pregunta si deseas cancelar la edición y, " +
            "además, cerrar la ventana en el caso de \"Crear ofertas\" y de \"Ajestes\". También te puedes " +
            "identificar como empresa mandandonos un correo, para ello selecciona la opción \"Validar " +
            "Empresa\", se abrirá la aplicación de correo desde la que nos podrás indicar la validación" +
            "pertinente. Otra de las opciones que puedes realizar es la de eliminar tu cuenta, para ello " +
            "selecciona la opción de \"Eliminar Usuario\". Por último, para cerrar sesión tendrás que " +
            "presionar la opción \"Cerrar Sesión\" del menú lateral."
        helpTextView.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    
    @IBAction func close(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
