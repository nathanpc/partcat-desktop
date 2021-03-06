#!/usr/bin/perl

package UI::MainWindow;

use strict;
use warnings;

use Tkx;
use Carp;
use Try::Tiny;

# Constructor.
sub new {
	my ($class, $title) = @_;
	my $self = {
		mw => Tkx::widget->new("."),
	};

	# Bless the reference.
	bless $self, $class;

	# Setup styling.
	try {
		Tkx::package_require("style");
		Tkx::style__use("as", -priority => 70);
	} catch {
		carp "Tk 'style' package wasn't found. Make sure you have 'tklib' installed";
		exit;
	};

	# Set the window title and layout the components.
	$self->{mw}->g_wm_title($title);
	$self->_setup_menus;
	$self->_setup_layout;

	return $self;
}

# Starts the Tk main loop.
sub show {
	my ($self) = @_;
	Tkx::MainLoop();
}

# Sets up all the menus.
sub _setup_menus {
	my ($self) = @_;

	# Remove tearoff.
	Tkx::option_add("*tearOff", 0);

	# Create the menu and assign it to the window.
	my $menu = $self->{mw}->new_menu;
	$self->{mw}->configure(-menu => $menu);

	# File menu.
	my $m_file = $menu->new_menu;
	$menu->add_cascade(-menu => $m_file, -label => "File");
	$m_file->add_command(-label => "Quit", -command => \&Tkx::exit);

	# Edit menu.
	my $m_edit = $menu->new_menu;
	$menu->add_cascade(-menu => $m_edit, -label => "Edit");

	# Server menu.
	my $m_server = $menu->new_menu;
	$menu->add_cascade(-menu => $m_server, -label => "Server");
	$m_server->add_command(-label => "Connect");
	$m_server->add_command(-label => "Disconnect");
	$m_server->add_separator;
	$m_server->add_command(-label => "Set Location");
	$m_server->add_command(-label => "Set Credentials");
	$m_server->add_command(-label => "Save Configuration");
}

# Lays out all of the components.
sub _setup_layout {
	my ($self) = @_;

	# Setup the mother frame.
	#my $f_main = $self->{mw}->new_ttk__frame;
	#$f_main->g_grid(-column => 0, -row => 0, -sticky => "nwes");

	# Setup the root window to fill with the main widget.
	$self->{mw}->g_grid_columnconfigure(0, -weight => 1);
	$self->{mw}->g_grid_rowconfigure(0, -weight => 1);

	# Setup the main tab view and its frames.
	my $n_main = $self->{mw}->new_ttk__notebook;
	$n_main->g_grid(-column => 0, -row => 0, -sticky => "nwes");
	my $f_comp = $n_main->new_ttk__frame(-padding => 5);
	my $f_cat = $n_main->new_ttk__frame(-padding => 5);
	my $f_img = $n_main->new_ttk__frame(-padding => 5);
	$n_main->add($f_comp, -text => "Components");
	$n_main->add($f_cat, -text => "Categories");
	$n_main->add($f_img, -text => "Images");

	# Setup components tab.
	$self->_setup_component_tab($f_comp);
}

# Sets up the component search tab layout.
sub _setup_component_tab {
	my ($self, $frm) = @_;

	# Setup grid weights.
	$frm->g_grid_columnconfigure(0, -weight => 1);
	$frm->g_grid_rowconfigure(1, -weight => 1);

	# Search Frame.
	my $f_search = $frm->new_ttk__labelframe(-text => "Search", -padding => 5);
	$f_search->g_grid_columnconfigure(1, -weight => 1);
	$f_search->g_grid(-column => 0, -row => 0, -sticky => "nwe");

	# Search Entry.
	my $l_smpn = $f_search->new_ttk__label(-text => "Part Number");
	my $e_smpn = $f_search->new_ttk__entry;
	$l_smpn->g_grid(-column => 1, -row => 0, -sticky => "nw");
	$e_smpn->g_grid(-column => 1, -row => 1, -sticky => "nwes");
	my $b_search = $f_search->new_ttk__button(-text => "Search");
	$b_search->g_grid(-column => 2, -row => 0, -rowspan => 2, -padx => "5 0", -sticky => "nwes");

	# Results Frame.
	my $f_results = $frm->new_ttk__labelframe(-text => "Results", -padding => 5);
	$f_results->g_grid_columnconfigure(0, -weight => 1);
	$f_results->g_grid_rowconfigure(0, -weight => 1);
	$f_results->g_grid(-column => 0, -row => 1, -pady => "5 0", -sticky => "nwes");

	# Component TreeView.
	my $t_comp = $f_results->new_ttk__treeview(-columns => "qnt desc");
	$t_comp->configure(-selectmode => "browse");
	$t_comp->g_grid(-column => 0, -row => 0, -sticky => "nwes");
	$t_comp->column("#0", -width => 100);
	$t_comp->heading("#0", -text => "Part Number");
	$t_comp->column("qnt", -anchor => "center", -width => 20);
	$t_comp->heading("qnt", -text => "Qty");
	$t_comp->column("desc", -anchor => "w", -width => 300);
	$t_comp->heading("desc", -text => "Description");

	# Component View Frame.
	my $f_comp = $frm->new_ttk__labelframe(-text => "Component", -padding => 5, -width => 400);
	$f_comp->g_grid_rowconfigure(9, -weight => 1);
	$f_comp->g_grid(-column => 1, -row => 0, -rowspan => 2, -padx => "10 0", -sticky => "nwes");

	# Main component data.
	#my $l_img = $f_comp->new_ttk__label();
	my $l_id = $f_comp->new_ttk__label(-text => "ID");
	my $e_id = $f_comp->new_ttk__entry(-state => "disabled");
	$l_id->g_grid(-column => 1, -row => 0, -sticky => "nwe");
	$e_id->g_grid(-column => 1, -row => 1, -sticky => "nwe");
	my $l_qnt = $f_comp->new_ttk__label(-text => "Quantity");
	my $s_qnt = $f_comp->new_ttk__spinbox(-from => 0.0, -increment => 1.0);
	$l_qnt->g_grid(-column => 2, -row => 0, -padx => "5 0", -sticky => "nwe");
	$s_qnt->g_grid(-column => 2, -row => 1, -padx => "5 0", -sticky => "nwe");
	my $l_cat = $f_comp->new_ttk__label(-text => "Category");
	my $c_cat = $f_comp->new_ttk__combobox(-values => "Op-Amp Transistor Test");
	$l_cat->g_grid(-column => 1, -row => 2, -columnspan => 2, -sticky => "nwe");
	$c_cat->g_grid(-column => 1, -row => 3, -columnspan => 2, -sticky => "nwe");
	my $l_mpn = $f_comp->new_ttk__label(-text => "Part Number");
	my $e_mpn = $f_comp->new_ttk__entry;
	$l_mpn->g_grid(-column => 1, -row => 4, -columnspan => 2, -sticky => "nwe");
	$e_mpn->g_grid(-column => 1, -row => 5, -columnspan => 2, -sticky => "nwe");
	my $l_desc = $f_comp->new_ttk__label(-text => "Description");
	my $e_desc = $f_comp->new_ttk__entry;
	$l_desc->g_grid(-column => 0, -row => 6, -columnspan => 3, -sticky => "nwe");
	$e_desc->g_grid(-column => 0, -row => 7, -columnspan => 3, -sticky => "nwe");
	my $l_param = $f_comp->new_ttk__label(-text => "Component Parameters");
	my $t_param = $f_comp->new_ttk__treeview(-columns => "key value");
	$l_param->g_grid(-column => 0, -row => 8, -columnspan => 3, -sticky => "nwe");
	$t_param->configure(-show => "headings", -selectmode => "browse");
	$t_param->g_grid(-column => 0, -row => 9, -columnspan => 3, -sticky => "nwes");
	$t_param->heading("key", -text => "Parameter");
	$t_param->heading("value", -text => "Value");

	# Test populate the treeview.
	$t_comp->insert("", "end", -id => "1", -text =>  "Voltage Regulators", -open => 1);
	$t_comp->insert("1", "end", -id => "2", -text => "LM317", -values => [ 11, "Simple voltage regulator thing"], -open => 1);
	$t_comp->insert("1", "end", -text => "LM317", -values => [ 12, "Simple voltage regulator thing"], -open => 1);
	$t_comp->insert("", "end", -id => "3", -text => "Others", -open => 1);
	$t_comp->insert("3", "end", -text => "TLV4231", -values => [ 5, "Op-Amp thing"], -open => 1);
}

1;

__END__

=head1 NAME

UI::MainWindow - Main window of the GUI application.

=head1 SYNOPSIS

  # Write some sample code.

=head1 METHODS

=over 4

=item I<$mw> = C<UI::MainWindow>->C<new>(I<$title>)

Initializes the main window object with a I<$title>.

=item I<$mw>->C<show>

Starts the Tk main loop.

=back

=head1 PRIVATE METHODS

=over 4

=item I<$self>->C<_setup_menus>()

Places all the menu items in the menubar of the window.

=item I<$self>->C<_setup_layout>()

Places all the "main" layout pieces into the window.

=item I<$self>->C<_setup_component_tab>(I<$frm>)

Places all the component tab widgets inside the designated frame in I<$frame>.

=back

=head1 AUTHOR

Nathan Campos <nathan@innoveworkshop.com>

=head1 COPYRIGHT

Copyright (c) 2019- Innove Workshop Company.

=cut

