const express = require('express');
const mysql = require('mysql2');
const socketio = require('socket.io');

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));


const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'huawie_notepad_project'
});
if (db.connect) {
    console.log('database connected!')
} else {
    console.error(db);
}

let io;

// inserting data route 
app.post('/api/insert', (req, res) => {
    let query = 'INSERT INTO notes SET Title=?,Content=?';
    const { Title, Content } = req.body;

    db.query(query, [Title, Content], (err, ok) => {
        if (err) {
            console.error(err);

        } else {
            res.send('data inserted!');
            io.emit('new-note', { Title, Content });


        }
    });
});


//fetching data route 
app.get('/api/fetch', (req, res) => {
    let query = 'SELECT * FROM notes';

    db.query(query, (err, ok) => {
        if (err) {
            console.error(err);
        } else {
            res.send(ok);
            // io.emit('notes-updated', ok);
        }

    });
});


const server = app.listen(5000, () => {
    console.log('server created!');
    io = socketio(server)

    io.on('connection', socket => {
        console.log('new user connected!');
        console.log(socket.id);
        socket.on('disconnect!', () => {
            console.log('user disconected1');
        });
    });
});
