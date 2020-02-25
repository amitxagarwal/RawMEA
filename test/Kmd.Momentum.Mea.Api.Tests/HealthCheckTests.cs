using System;
using System.Net;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace Kmd.Momentum.Mea.Api.Tests
{
    public class HealthCheckTests : IClassFixture<WebApplicationFactory<Startup>>
    {
        private readonly WebApplicationFactory<Startup> _factory;

        public HealthCheckTests(WebApplicationFactory<Startup> factory)
        {
            _factory = factory;
        }

        [Fact]
        public async Task TheHealthEndpointResponds200()
        {
            //Arrange
            var client = _factory.CreateClient();

            //Act
            var response = await client.GetAsync(new Uri("/health/ready", UriKind.Relative)).ConfigureAwait(false);

            //Assert
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        }

        // [Fact]
        // public async Task TheHealthEndPointResponds401UnauthorizedIfNoTokenIsUsed()
        // {
        //     //Arrange
        //     var client = _factory.CreateClient();
           
        //     //Act
        //     var response = await client.GetAsync(new Uri("/health/ready", UriKind.Relative)).ConfigureAwait(false);

        //     //Assert
        //     Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        // }
    }
}