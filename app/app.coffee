require('coffee-script')
flash = require('connect-flash')
express = require('express')
passport = require('passport')
LocalStrategy = require('passport-local').Strategy
auth = require('../lib/auth').Auth

authentication = new auth()

passport.serializeUser( (user, done) ->
   
    return done(null, user.id)
)

passport.deserializeUser( (id, done) ->
    
    authentication.getUserById( id,  (error, result) ->

        return done(error, result)
    )
)


passport.use(new LocalStrategy(
    passReqToCallback: true
    (req, username, password, done) ->
        req.flash('username', username)
        authentication.login(username, password, done)
))

app = express()

app.configure(
    app.use(express.static(__dirname + '/public'))
    app.use(express.bodyParser())
    app.set('view engine', 'jade')
    app.set('view options',
        layout: false
    )
    app.use(express.cookieParser('keyboard cat'))
    app.use(express.session({cookie: {maxAge: 60000}}))
    app.use(passport.initialize())
    app.use(passport.session())
    app.use(flash())
)

app.get('/', (req, res) ->

    res.write('Hello World')
    res.end()
)

app.get('/login', (req, res) ->
   
    username = req.flash('username')[0]

    res.render('../templates/login.jade', {username: username}, (err, html) ->
       
        res.write(html)
        res.end()
    )
)

app.post('/login',
passport.authenticate('local',
       failureRedirect: '/login'
       failureFlash: true
   ), (req, res) ->

       res.write('Success')
       res.end()
   )

app.get('/test', (req, res) ->

    res.write(req.user.toString())
    res.end()
)


app.listen(8080)
console.log('listening on 8080')
