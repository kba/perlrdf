use FindBin '$Bin';
use lib "$Bin/lib";
use Data::Dumper;

use Test::More;

use RDF::Trine qw(iri literal statement);
use Test::RDF::Trine::Store qw(all_store_tests number_of_tests);

# setting up endpoint and Plack-aware LWP::UserAgent

use_ok RDF::Endpoint;
use_ok LWP::Protocol::PSGI;

my $end_config  = {
    store => 'Memory',
    endpoint    => {
        endpoint_path   => '/',
        update      => 1,
        load_data   => 1,
        html        => {
            resource_links  => 1,    # turn resources into links in HTML query result pages
            embed_images    => 0,    # display foaf:Images as images in HTML query result pages
            image_width     => 200,  # with 'embed_images', scale images to this width
        },
        service_description => {
            default         => 1,    # generate dataset description of the default graph
            named_graphs    => 1,    # generate dataset description of the available named graphs
        },
    },
};
my $end_model = RDF::Trine::Model->temporary_model;
my $end     = RDF::Endpoint->new( $end_model, $end_config );
my $end_app = sub {
    my $env 	= shift;
    my $req 	= Plack::Request->new($env);
    my $resp	= $end->run( $req );
    return $resp->finalize;
};
LWP::Protocol::PSGI->register($end_app);

my $ua = LWP::UserAgent->new;
#warn Dumper $ua->get("http://localhost/");

# setting up SPARQL store

my $store = RDF::Trine::Store::SPARQL->new( "http://localhost/", $ua );
my $sparql_model = RDF::Trine::Model->new( $store );

#my $s1  =statement(iri(':a'), iri(':b'), literal("c"));
#warn Dumper $s1;
#$store->add_statement( $s1, iri( ":contenxt" ) );
#$store->add_statement( $s1 );
#
#warn Dumper $store->size();
#warn Dumper $end_model->size();



#
my $data = Test::RDF::Trine::Store::create_data;
Test::RDF::Trine::Store::all_store_tests( $store, $data );

