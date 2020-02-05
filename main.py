from flask import Flask, request, session, redirect, url_for, render_template
from flask_mysqldb import MySQL
from werkzeug.utils import secure_filename
import os
app = Flask(__name__,
            static_url_path='',
            static_folder='static',
            template_folder='templates')
# Configuracion a MySQL
# 1.-Servidor a conectarse
app.config['MYSQL_HOST'] = 'localhost'
# 2.-Usuario a conectarse
app.config['MYSQL_USER'] = 'root'
# 3.-Password del usuario
app.config['MYSQL_PASSWORD'] = ''
# 4.-La BD a conectarme
app.config['MYSQL_DB'] = 'bdecomerce6'
# 5.-Configurar la informacion a conectarse en modo diccionario
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'
# Creo el objeto mysql que tendra la aplicacion conectada al servidor
mysql = MySQL(app)
@app.route('/login', methods=['GET', 'POST'])
def login():
    msg = ""
    if request.method == "POST" and 'username' in request.form and 'password' in request.form:
        username = request.form['username']
        password = request.form['password']
        cur = mysql.connection.cursor()
        # cur.execute('SELECT * FROM usuarios WHERE usuario= %s AND password =%s', (username, password))
        # cur.callproc('login_usuarios', [username, password])
        cur.callproc('login', [username, password])
        usuarios = cur.fetchone()
        if usuarios:
            session['loggedin'] = True
            session['id'] = usuarios['codigo']
            session['username'] = usuarios['usuario']
            # return 'Usuario Conectado'
            return redirect(url_for('home'))
        else:
            msg = 'Usuario No Existe en la BD'
    return render_template('login.html', msg=msg)
@app.route('/home')
def home():
    # chequear si el usuario esta logeado
    if 'loggedin' in session:
        cur = mysql.connection.cursor()
        # cur.execute('SELECT * FROM usuarios where codigo =%s', [session['id']])
        cur.callproc('usuario_codigo', [session['id']])
        usuario = cur.fetchone()
        return render_template('home.html', username=session['username'], usuario=usuario)
    return redirect(url_for('login'))
@app.route('/profile')
def profile():
    if 'loggedin' in session:
        cur = mysql.connection.cursor()
        #cur.execute('SELECT * FROM usuarios where codigo =%s', [session['id']])
        cur.callproc('usuario_codigo', [session['id']])
        usuario = cur.fetchone()
        return render_template('profile.html', usuario=usuario)
    return redirect(url_for('login'))
@app.route('/logout')
def logout():
    #Remover los datos de la session
    session.pop('loggedin', None)
    session.pop('id', None)
    session.pop('username', None)
    #Redirecionar al login
    return redirect(url_for('login'))

app.config["IMAGE_UPLOADS"] = "/ESTUDIOS/BootCamp/usb2/nuevologin/6ECOMMERCE_REGISTRAR/static/img"

@app.route('/registrar', methods=['GET', 'POST'])
def registrar():
    msg = ""
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form and 'email' in request.form:
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        cur = mysql.connection.cursor()
        cur.callproc('usuario_user', [username])
        account = cur.fetchone()
        cur.close()
        if account:
            msg = "Usuario Ya Existe"
        elif not username or not password or not email:
            msg = "Debe Llenar todos los campos del Formulario"
        else:
            if request.files:
                image = request.files["image"]
                image.save(os.path.join(app.config["IMAGE_UPLOADS"], image.filename))
                cur = mysql.connection.cursor()
                cur.callproc('insertar_usuario', [username, password, email, 'img/' + image.filename])
                mysql.connection.commit()
                msg = 'El usuario se Grabo con Exito'
            else:
                msg = 'Debe seleccionar una imagen para su perfil'
    elif request.method == 'POST':
        msg = 'Por Favor Llene Los Campos en el Formulario!'
    return render_template('registrar.html', msg=msg)


@app.route('/productos')
def productos():
    cur=mysql.connection.cursor()
    result=cur.execute("SELECT * FROM PRODUCTOS")
    prod = cur.fetchall()
    if result>0:
        cur = mysql.connection.cursor()
        # cur.execute('SELECT * FROM usuarios where codigo =%s', [session['id']])
        cur.callproc('usuario_codigo', [session['id']])
        usuario = cur.fetchone()
        return render_template('productos.html',prod=prod,usuario=usuario)
    else:
        cur = mysql.connection.cursor()
        # cur.execute('SELECT * FROM usuarios where codigo =%s', [session['id']])
        cur.callproc('usuario_codigo', [session['id']])
        usuario = cur.fetchone()
        msg="No existe Productos que mostrar"
        return render_template('productos.html',msg=msg, usuario=usuario)
        cur.close

@app.route('/registrarproductos', methods=['GET', 'POST'])
def registrarproductos():
    msg = ""
    if request.method == 'POST':
        categoria = request.form['categoria']
        nombre = request.form['nombre']
        descripcion = request.form['descripcion']
        precio = request.form['precio']
        stock = request.form['stock']
        foto = request.files["imagenfile"]
        cur = mysql.connection.cursor()
        cur.callproc('insertar_productos', [categoria, nombre, descripcion, precio, stock, 'img/' + foto.filename])
        mysql.connection.commit()
        msg = 'El usuario se Grabo con Exito'
    return redirect(url_for('productos'))
    cur.close

@app.route('/eliminar_producto/<int:id_data>', methods=['GET'])
def eliminar_producto(id_data):
    cur = mysql.connection.cursor()
    script_sql="delete from productos where cod="+str(id_data)
    print(script_sql)
    cur.execute(script_sql)
    mysql.connection.commit()
    cur.close()
    return redirect(url_for('productos'))


@app.route('/modificarproductos', methods=['POST'])
def modificarproductos():
    codigo = request.form['codigo']
    categoria = request.form['categoria']
    nombre = request.form['nombre']
    descripcion = request.form['descripci,on']
    precio = request.form['precio']
    stock = request.form['stock']
    foto = request.files["imagenfile"]
    cur = mysql.connection.cursor()
    cur.execute("update productos set categoria=%s, nombre=%s, descripcion=%s, precio=%s, stock=%s where cod=%s", (categoria, nombre, descripcion, precio, stock, codigo))
    mysql.connection.commit()
    msg = 'El producto se actualizo con Exito'
    cur.close
    return redirect(url_for('productos'))

@app.route('/categorias')
def categorias():

    cur=mysql.connection.cursor()
    result = cur.execute("SELECT * FROM CATEGORIA")
    categ = cur.fetchall()
    # cur.execute('SELECT * FROM usuarios where codigo =%s', [session['id']])
    cur.callproc('usuario_codigo', [session['id']])
    usuario = cur.fetchone()



    cur.close()
    return render_template('categorias.html',categ=categ, usuario=usuario)



@app.route('/registrarcategorias', methods=['GET', 'POST'])
def registrarcategorias():
    msg = ""
    if request.method == 'POST':
        nombre = request.form['nombre']
        #estado = request.form['estado']
        cur = mysql.connection.cursor()
        cur.callproc('insertar_categoria', [nombre])
        mysql.connection.commit()
        msg = 'La Categoria se Grabo con Exito'
        cur.close
    return redirect(url_for('categorias'))


@app.route('/eliminar_categoria/<int:id_data>', methods=['GET'])
def eliminar_categoria(id_data):
    cur = mysql.connection.cursor()
    script_sql="delete from categoria where cod="+str(id_data)
    print(script_sql)
    cur.execute(script_sql)
    mysql.connection.commit()
    cur.close()
    return redirect(url_for('categorias.html'))


@app.route('/modificarcategorias', methods=['POST'])
def modificarcategorias():
    codCategoria = request.form['codCategoria']
    nombre = request.form['nombre']
    estado = request.form['estado']
    cur = mysql.connection.cursor()
    cur.execute("update categoria set nombre=%s,  cod=%s", (nombre, codCategoria,estado))
    mysql.connection.commit()
    msg = 'La Categoria se actualizo con Exito'
    cur.close
    return redirect(url_for('categorias.html'))

@app.route('/product')
def product():
    if 'loggedin' in session:
        cur = mysql.connection.cursor()
        #cur.execute('SELECT * FROM usuarios where codigo =%s', [session['id']])
        cur.callproc('usuario_codigo', [session['id']])
        usuario = cur.fetchone()

        return render_template('product.html', usuario=usuario)
    return redirect(url_for('product'))

@app.route('/carrito')
def carrito():
    if 'loggedin' in session:
        cur = mysql.connection.cursor()
        # cur.execute('SELECT * FROM usuarios where codigo =%s', [session['id']])
        cur.callproc('usuario_codigo', [session['id']])
        usuario = cur.fetchone()
        return render_template('carrito.html', usuario=usuario)
    return redirect(url_for('carrito'))




if __name__ == "__main__":
    app.secret_key = 'codigo2020'
app.run(debug=True, port=3000)
