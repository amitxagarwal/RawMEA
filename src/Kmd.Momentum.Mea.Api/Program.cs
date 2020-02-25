using System;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog;
using Serilog.Events;

namespace Kmd.Momentum.Mea.Api
{
    public static class Program
    {
        public static string GetEnvironmentInstanceId(IConfiguration configuration) =>
            configuration.GetValue("EnvironmentInstanceId", defaultValue: Environment.MachineName);

        public static void Main(string[] args)
        {
            var config = new ConfigurationBuilder().AddEnvironmentVariables(prefix: "KMD_MOMENTUM_MEA_").AddCommandLine(args).Build();
            var consoleMinLevel = config.GetValue("ConsoleLoggingMinLevel", defaultValue: LogEventLevel.Debug);
            var aspnetCoreLevel = config.GetValue("AspNetCoreLevel", defaultValue: LogEventLevel.Information);
            var seqServerUrl = config.GetValue("DiagnosticSeqServerUrl", defaultValue: "http://localhost:5341/");
            var seqApiKey = config.GetValue("DiagnosticSeqApiKey", defaultValue: "");
            var applicationName = typeof(Program).Assembly.GetName().Name;
            var slotName = config.GetValue("SlotName", defaultValue: "localdev");
            var environmentInstanceId = GetEnvironmentInstanceId(config);

            Log.Logger = new LoggerConfiguration()
                .Enrich.FromLogContext()
                .MinimumLevel.Verbose()
                .MinimumLevel.Override("Microsoft.AspNetCore", aspnetCoreLevel)
                .Enrich.WithProperty("Application", applicationName)
                .Enrich.WithProperty("SlotName", slotName)
                .Enrich.WithProperty("EnvironmentInstanceId", environmentInstanceId)
                .WriteTo.Console(restrictedToMinimumLevel: consoleMinLevel)
                .WriteTo.Seq(serverUrl: seqServerUrl, apiKey: seqApiKey, compact: true)
                .WriteTo.ApplicationInsights(TelemetryConfiguration.Active, TelemetryConverter.Traces)
                .CreateLogger();

            try
            {
                Log.Information("Starting up");
                using var host = CreateConfigurableHostBuilder(args, config).Build();
                host.Run();
            }
            catch (Exception ex)
            {
                Log.Fatal(ex, "A fatal exception was encoutered");
                throw;
            }
            finally
            {
                Log.CloseAndFlush();
            }
        }

        // NOTE: this exact signature is required by tooling such as the testing infrastructure
        public static IHostBuilder CreateHostBuilder(string[] args) => CreateConfigurableHostBuilder(args, config: null);

        public static IHostBuilder CreateConfigurableHostBuilder(string[] args, IConfiguration config) =>
            Host.CreateDefaultBuilder(args)
                .UseSerilog()
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder
                        .ConfigureAppConfiguration(builder =>
                        {
                            if (config != null) builder.AddConfiguration(config);
                        })
                        .UseStartup<Startup>();
                });
    }
}
