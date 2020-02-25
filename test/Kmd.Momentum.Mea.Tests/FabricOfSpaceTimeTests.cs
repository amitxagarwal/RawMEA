using FluentAssertions;
using Xunit;

namespace Kmd.Momentum.Mea.Tests
{
    public class FabricOfSpaceTimeTests
    {
        [Fact]
        public void IsCorrectUniverse()
        {
            true.Should().BeTrue(because: "In this universe, 'true' definitely is 'true'");
        }
    }
}