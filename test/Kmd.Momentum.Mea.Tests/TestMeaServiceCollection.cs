using Microsoft.Extensions.DependencyInjection;
using Moq;

namespace Kmd.Momentum.Mea.Tests
{
    public class TestMeaServiceCollection
    {
        private readonly ServiceCollection collection;

        public TestMeaServiceCollection()
        {
            this.collection = new ServiceCollection();
            this.collection.AddMea();
        }

        public TestMeaServiceCollection WithMock<TMockedService>(Mock<TMockedService> mock)
            where TMockedService : class
        {
            if (mock is null)
            {
                throw new System.ArgumentNullException(nameof(mock));
            }

            this.collection.AddSingleton(mock.Object);
            return this;
        }

        public IServiceScope Build() => collection.BuildServiceProvider().CreateScope();
    }
}