%% This is the application resource file (.app file) for the 'base'
%% application.
{application, service,
[{description, "service  " },
{vsn, "1.0.0" },
{modules, 
	  [service_app,service_sup,service,service_control]},
{registered,[service]},
{applications, [kernel,stdlib]},
{mod, {service_app,[]}},
{start_phases, []}
]}.
