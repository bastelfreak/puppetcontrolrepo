class profiles::prometheus {
  include ferm
  include nginx
  class{'prometheus::server':
    version => '2.3.1',
  }
}
