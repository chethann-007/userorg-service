# Play Framework Upgrade & Akka to Pekko Migration - Compatibility Report

## Executive Summary

This report provides a comprehensive analysis of upgrading Play Framework and migrating from Akka to Apache Pekko in the userorg-service repository. The migration is necessary because Akka changed its license from open source (Apache 2.0) to the Business Source License (BSL) v1.1, making it unsuitable for many open-source projects.

**Current State:**
- **Play Framework Version:** 2.7.2 (Released April 2019)
- **Akka Version:** 2.5.22 (Released April 2019)
- **Scala Version:** 2.12.11
- **Java Version:** 11
- **Build Tool:** Maven with play2-maven-plugin

**Recommended Target:**
- **Play Framework:** 2.9.x (Last version supporting Akka before Pekko migration)
- **Apache Pekko:** 1.0.x (Direct Akka fork by Apache)
- **Alternative:** Play Framework 3.0.x with Pekko (requires more significant changes)

---

## 1. Current Architecture Analysis

### 1.1 Project Structure

The userorg-service is a multi-module Maven project with the following structure:

```
userorg-service/
├── core/
│   ├── actor-core/          # Base actor implementation
│   ├── platform-common/     # Common utilities with Akka dependencies
│   ├── cassandra-utils/
│   ├── es-utils/
│   └── notification-utils/
├── service/                 # Business logic with Actor implementations
├── controller/              # Play Framework web layer
└── reports/                 # Reporting module
```

### 1.2 Akka Usage Assessment

**Quantitative Analysis:**
- **Java files with Akka imports:** 128 files
- **Actor implementations (non-test):** ~60 actors
- **Akka-related lines of code:** ~397 occurrences

**Key Akka Components Used:**

1. **Actor System & Actors:**
   - `akka.actor.ActorSystem`
   - `akka.actor.ActorRef`
   - `akka.actor.ActorSelection`
   - `akka.actor.UntypedAbstractActor` (Base class for all actors)
   - `akka.actor.Props`

2. **Actor Patterns:**
   - `akka.pattern.PatternsCS` (Ask pattern for request-response)
   - `akka.util.Timeout`

3. **Routing:**
   - `akka.routing.FromConfig`
   - `akka.routing.RouterConfig`
   - Smallest-mailbox-pool routing strategy
   - Custom dispatchers (fork-join executors)

4. **Testing:**
   - `akka.testkit.javadsl.TestKit`
   - `akka.dispatch.Futures` (for mocking async operations)

5. **Serialization:**
   - Custom Java serialization for Request/Response objects
   - `akka.serialization.JavaSerializer`

6. **Streams:**
   - `akka.stream` (via Play dependencies)

7. **HTTP:**
   - `akka.http` (via play-akka-http-server)

### 1.3 Play Framework Integration

**Play-Akka Integration Points:**

1. **Dependency Injection:**
   ```java
   // ActorStartModule.java
   public class ActorStartModule extends AbstractModule implements AkkaGuiceSupport
   ```
   - Uses `play.libs.akka.AkkaGuiceSupport` for actor binding
   - Binds actors with router configuration
   - Integrates with Guice for dependency injection

2. **Actor Module Configuration:**
   ```java
   play.modules {
     enabled += modules.StartModule
     enabled += modules.ActorStartModule
   }
   ```

3. **HTTP Request Handling:**
   - Controllers use `actorResponseHandler()` to communicate with actors
   - Returns `CompletionStage<Result>` for async responses
   - Uses Akka's ask pattern for request-response

### 1.4 Actor Implementations

**Main Actor Classes:**

1. **Base Actor:** `org.sunbird.actor.core.BaseActor`
   - Extends `UntypedAbstractActor`
   - Provides error handling wrapper
   - Used by all business logic actors

2. **Service Actors (20+ actors):**
   - `OrganisationManagementActor`
   - `UserManagementActor`
   - `LocationActor`
   - `HealthActor`
   - `SystemSettingsActor`
   - `OTPActor`, `SendOTPActor`
   - `UserConsentActor`
   - `SearchHandlerActor`
   - `EsSyncActor`
   - `FileUploadServiceActor`
   - Various bulk upload actors
   - Background job actors

3. **Dispatcher Configuration:**
   - `rr-usr-dispatcher` (8-64 threads)
   - `brr-usr-dispatcher` (1-4 threads)
   - `most-used-one-dispatcher` (8-64 threads)
   - `most-used-two-dispatcher` (8-64 threads)
   - `health-check-dispatcher` (1-2 threads)
   - `notification-dispatcher` (8-64 threads)

### 1.5 Configuration Files

**application.conf (800 lines):**
- Extensive Akka configuration (lines 8-400+)
- Actor deployment configuration
- Custom dispatcher settings
- Router pools for load balancing
- Serialization bindings

---

## 2. Upgrade Paths & Options

### 2.1 Option 1: Incremental Upgrade to Play 2.9.x + Stay with Akka (Short-term)

**Path:**
- Upgrade Play: 2.7.2 → 2.8.x → 2.9.x
- Keep Akka: 2.5.22 → 2.6.x
- **NOT RECOMMENDED** - This is only a temporary solution due to Akka licensing

**Effort:** Medium (2-3 weeks)

**Pros:**
- Smaller incremental changes
- Tests existing upgrade path
- Defers major refactoring

**Cons:**
- Akka license issue remains
- Will need to migrate eventually anyway
- Play 2.9.x is outdated (last release March 2023)
- Double migration effort later

### 2.2 Option 2: Upgrade to Play 2.9.x + Migrate to Pekko 1.0.x (Recommended)

**Path:**
- Upgrade Play: 2.7.2 → 2.9.x
- Migrate Actors: Akka 2.6.x → Apache Pekko 1.0.x
- Use Pekko-compatible Play libraries

**Effort:** Medium-High (4-6 weeks)

**Pros:**
- Resolves licensing issues
- Pekko 1.0.x is API-compatible with Akka 2.6.x
- Minimal code changes (mostly package renames)
- Community-supported Play-Pekko integration available
- Stable migration path with documented examples

**Cons:**
- Requires testing all actor functionality
- Play 2.9.x is still outdated
- May need custom integration glue

### 2.3 Option 3: Upgrade to Play 3.0.x + Migrate to Pekko 1.0.x (Future-proof)

**Path:**
- Upgrade Play: 2.7.2 → 2.8.x → 2.9.x → 3.0.x
- Migrate to Pekko 1.0.x
- Update to Scala 2.13 or 3.x
- Update Guice and other dependencies

**Effort:** High (8-12 weeks)

**Pros:**
- Most future-proof solution
- Play 3.0.x has native Pekko support
- Latest features and security updates
- Official Pekko integration
- Long-term support

**Cons:**
- Significant breaking changes in Play 3.0
- Requires Scala version upgrade
- More extensive testing required
- Higher risk of regression

### 2.4 Option 4: Consider Alternative Frameworks (Not Recommended)

**Alternatives:**
- Spring Boot with WebFlux
- Vert.x
- Micronaut

**Pros:**
- No Akka dependency
- Modern framework features

**Cons:**
- Complete rewrite required (6-12 months)
- High risk
- Loss of existing architecture investment
- Not feasible for this project

---

## 3. Detailed Migration Analysis

### 3.1 Package Name Changes (Akka → Pekko)

The migration from Akka to Pekko primarily involves package renaming:

| Akka Package | Pekko Package |
|--------------|---------------|
| `akka.*` | `org.apache.pekko.*` |
| `com.typesafe.akka` | `org.apache.pekko` |

**Affected Files (128 Java files):**

**Core Module:**
- `core/actor-core/src/main/java/org/sunbird/actor/core/BaseActor.java`
  ```java
  // Before
  import akka.actor.UntypedAbstractActor;
  
  // After
  import org.apache.pekko.actor.UntypedAbstractActor;
  ```

**Controller Module:**
- All files in `controller/app/controllers/`
- All files in `controller/app/modules/`
  ```java
  // Before
  import akka.actor.ActorRef;
  import akka.pattern.PatternsCS;
  import play.libs.akka.AkkaGuiceSupport;
  
  // After
  import org.apache.pekko.actor.ActorRef;
  import org.apache.pekko.pattern.PatternsCS;
  import org.playframework.pekko.PekkoGuiceSupport; // Custom integration needed
  ```

**Service Module:**
- 60+ actor implementation files
- Test files using TestKit

### 3.2 Dependency Changes

**Current Dependencies (controller/pom.xml):**
```xml
<properties>
    <play2.version>2.7.2</play2.version>
    <typesafe.akka.version>2.5.22</typesafe.akka.version>
    <scala.major.version>2.12</scala.major.version>
</properties>

<dependency>
    <groupId>com.typesafe.play</groupId>
    <artifactId>play-guice_${scala.major.version}</artifactId>
    <version>${play2.version}</version>
</dependency>

<dependency>
    <groupId>com.typesafe.akka</groupId>
    <artifactId>akka-slf4j_${scala.major.version}</artifactId>
    <version>${typesafe.akka.version}</version>
</dependency>

<dependency>
    <groupId>com.typesafe.akka</groupId>
    <artifactId>akka-testkit_${scala.major.version}</artifactId>
    <version>${typesafe.akka.version}</version>
</dependency>
```

**Recommended Dependencies (Option 2: Play 2.9 + Pekko):**
```xml
<properties>
    <play2.version>2.9.3</play2.version>
    <pekko.version>1.0.2</pekko.version>
    <scala.major.version>2.13</scala.major.version>
</properties>

<dependency>
    <groupId>org.playframework</groupId>
    <artifactId>play-pekko-http-server_${scala.major.version}</artifactId>
    <version>${play2.version}</version>
</dependency>

<dependency>
    <groupId>org.apache.pekko</groupId>
    <artifactId>pekko-slf4j_${scala.major.version}</artifactId>
    <version>${pekko.version}</version>
</dependency>

<dependency>
    <groupId>org.apache.pekko</groupId>
    <artifactId>pekko-testkit_${scala.major.version}</artifactId>
    <version>${pekko.version}</version>
</dependency>
```

**For Play 3.0 (Option 3):**
```xml
<properties>
    <play2.version>3.0.0</play2.version>
    <pekko.version>1.0.2</pekko.version>
    <scala.major.version>2.13</scala.major.version>
</properties>

<!-- Play 3.0 has native Pekko support -->
<dependency>
    <groupId>org.playframework</groupId>
    <artifactId>play_${scala.major.version}</artifactId>
    <version>${play2.version}</version>
</dependency>
```

### 3.3 Configuration Changes

**application.conf:**

```hocon
# Before (Akka)
akka {
  stdout-loglevel = "OFF"
  loglevel = "OFF"
  actor {
    provider = "akka.actor.LocalActorRefProvider"
    serializers {
      java = "akka.serialization.JavaSerializer"
    }
    # ...
  }
}

# After (Pekko)
pekko {
  stdout-loglevel = "OFF"
  loglevel = "OFF"
  actor {
    provider = "org.apache.pekko.actor.LocalActorRefProvider"
    serializers {
      java = "org.apache.pekko.serialization.JavaSerializer"
    }
    # ...
  }
}
```

**Play Module Changes:**

For Play 2.9 + Pekko, you'll need custom integration:
```java
// Option: Use community library or create custom binding
// play-pekko-guice support may be available
```

For Play 3.0, native support is available:
```java
import org.playframework.pekko.PekkoGuiceSupport;

public class ActorStartModule extends AbstractModule implements PekkoGuiceSupport {
    // Same code, just different import
}
```

### 3.4 Code Changes Required

**Minimal Changes (API Compatible):**

1. **Import Statements:** ~400-500 import statement changes
2. **Configuration:** ~100-200 configuration lines
3. **Dependencies:** ~20 POM changes

**No Changes Required:**
- Business logic in actors
- Actor message protocols
- Ask/tell patterns
- Router configuration logic
- Dispatcher configuration

**Example Migration:**

```java
// Before
package controllers;

import akka.actor.ActorRef;
import akka.pattern.PatternsCS;
import akka.util.Timeout;
import play.libs.akka.AkkaGuiceSupport;

public class BaseController extends Controller {
    public CompletionStage<Result> actorResponseHandler(
        Object actorRef,
        Request request,
        Timeout timeout,
        String responseKey,
        Request httpReq) {
        
        if (actorRef instanceof ActorRef) {
            return PatternsCS.ask((ActorRef) actorRef, request, timeout)
                .thenApplyAsync(function);
        }
        // ...
    }
}

// After (Pekko)
package controllers;

import org.apache.pekko.actor.ActorRef;
import org.apache.pekko.pattern.PatternsCS;
import org.apache.pekko.util.Timeout;
// For Play 2.9: Custom integration needed
// For Play 3.0: import org.playframework.pekko.PekkoGuiceSupport;

public class BaseController extends Controller {
    // Exact same implementation - no changes needed!
    public CompletionStage<Result> actorResponseHandler(
        Object actorRef,
        Request request,
        Timeout timeout,
        String responseKey,
        Request httpReq) {
        
        if (actorRef instanceof ActorRef) {
            return PatternsCS.ask((ActorRef) actorRef, request, timeout)
                .thenApplyAsync(function);
        }
        // ...
    }
}
```

---

## 4. Compatibility Matrix

### 4.1 Play Framework Versions

| Version | Akka Support | Pekko Support | Scala Version | Status | Notes |
|---------|--------------|---------------|---------------|--------|-------|
| 2.7.x | 2.5.x | No | 2.12, 2.13 | EOL | Current version |
| 2.8.x | 2.6.x | No | 2.12, 2.13 | EOL | Intermediate step |
| 2.9.x | 2.6.x | Community | 2.13 | Maintenance | Last Akka version |
| 3.0.x | No | 1.0.x (Native) | 2.13, 3.x | Active | Recommended |

### 4.2 Dependency Compatibility

| Component | Current | Play 2.9 + Pekko | Play 3.0 + Pekko |
|-----------|---------|------------------|------------------|
| Java | 11 | 11, 17 | 11, 17, 21 |
| Scala | 2.12.11 | 2.13.x | 2.13.x, 3.x |
| Jackson | 2.13.5 | 2.14.x | 2.15.x |
| Netty | 4.1.44 | 4.1.100+ | 4.1.100+ |
| Guice | 3.0 (old!) | 5.x | 6.x |
| SLF4J | 1.6.1 | 1.7.x | 2.x |

### 4.3 Breaking Changes

**Play 2.7 → 2.9:**
- Minimal breaking changes
- Deprecation warnings to address
- Some API changes in HTTP client

**Play 2.9 → 3.0:**
- Package renames: `play.*` → `org.playframework.*`
- Routing DSL changes
- Template engine updates
- Configuration format changes
- Java 11+ required
- Scala 2.13+ required

**Akka → Pekko:**
- Package renames (primary change)
- Configuration namespace change
- Binary compatibility maintained
- API compatibility maintained

---

## 5. Risks & Challenges

### 5.1 Technical Risks

**High Risk:**
1. **Integration Testing Coverage**
   - 60+ actors need thorough testing
   - Complex async flows with ask patterns
   - Routing and dispatcher behavior must be verified
   - Mitigation: Comprehensive integration test suite

2. **Custom Dispatcher Behavior**
   - 6 custom dispatchers with specific thread pool configs
   - Behavior changes between Akka/Pekko versions
   - Mitigation: Performance testing and monitoring

3. **Serialization**
   - Custom Java serialization for Request/Response
   - Version compatibility issues
   - Mitigation: Test serialization compatibility

**Medium Risk:**
1. **Third-party Dependencies**
   - Some libraries may still depend on Akka
   - Dependency conflicts possible
   - Mitigation: Thorough dependency analysis

2. **Play-Pekko Integration (for 2.9)**
   - Community support not official
   - May require custom glue code
   - Mitigation: Consider jumping to Play 3.0

3. **Performance Regression**
   - Thread pool behavior changes
   - Message throughput differences
   - Mitigation: Load testing

**Low Risk:**
1. **Actor Message Protocols**
   - No changes required
   - API-compatible

2. **Business Logic**
   - Unaffected by migration
   - No changes needed

### 5.2 Operational Risks

1. **Deployment Complexity**
   - New dependency versions
   - Configuration changes
   - Rollback strategy needed

2. **Documentation Updates**
   - Setup instructions need updating
   - Developer documentation changes
   - Operational runbooks update

3. **Team Training**
   - New package names
   - Pekko-specific changes
   - Testing approaches

### 5.3 Compatibility Issues

**Identified Issues:**

1. **Guice Version Conflict**
   - Current: Guice 3.0 (2011!)
   - Play 2.9 needs: Guice 5.x
   - Play 3.0 needs: Guice 6.x
   - Impact: May affect dependency injection across app

2. **Scala Version**
   - Current: 2.12.11
   - Play 3.0 requires: 2.13+
   - Impact: All Scala dependencies need update

3. **SBT vs Maven**
   - Play is primarily SBT-based
   - Using play2-maven-plugin
   - Plugin may lag behind Play releases
   - Impact: May need to switch to SBT

4. **Deprecated APIs**
   - `UntypedAbstractActor` (use TypedActor in future)
   - Old actor patterns
   - Impact: Technical debt to address

---

## 6. Benefits of Migration

### 6.1 Licensing Benefits

**Critical:**
- **Akka License Change:** BSL 1.1 (not open source)
  - Requires commercial license for production use at scale
  - Incompatible with many open-source licenses
  - Legal compliance risk

- **Pekko License:** Apache 2.0 (true open source)
  - No usage restrictions
  - Compatible with most open-source licenses
  - Community-driven development
  - Apache Software Foundation governance

**Financial:**
- Avoid Akka commercial licensing fees
- No vendor lock-in

### 6.2 Technical Benefits

**Play Framework Upgrade:**
1. Security patches and bug fixes
2. Performance improvements
3. Updated dependencies
4. Java 17/21 support (future)
5. Better tooling support

**Pekko Migration:**
1. API-compatible with Akka 2.6.x
2. Active community development
3. Apache Foundation backing
4. Continued evolution and improvements
5. Security updates

### 6.3 Future-Proofing

1. **Play 3.0:**
   - Native Pekko support
   - Modern features
   - Long-term support
   - Active development

2. **Apache Pekko:**
   - Growing ecosystem
   - Community-driven roadmap
   - No license surprises
   - Stable governance

3. **Ecosystem:**
   - More projects migrating to Pekko
   - Shared knowledge base
   - Third-party library support improving

---

## 7. Migration Strategy & Phases

### 7.1 Recommended Approach: Option 2 (Play 2.9 + Pekko)

**Phase 1: Preparation (1 week)**
1. Create feature branch
2. Set up test environment
3. Document current behavior
4. Create comprehensive test suite
5. Identify all Akka dependencies
6. Review third-party library compatibility

**Phase 2: Dependency Update (1 week)**
1. Update Play Framework: 2.7.2 → 2.9.x
2. Update Scala: 2.12.11 → 2.13.x
3. Update Guice: 3.0 → 5.x
4. Update other dependencies
5. Fix compilation errors
6. Run tests

**Phase 3: Akka to Pekko Migration (2 weeks)**
1. Update Maven dependencies
2. Run automated package rename tool
3. Update configuration files
4. Update custom integration code
5. Update test utilities
6. Fix compilation errors

**Phase 4: Testing & Validation (2 weeks)**
1. Unit test execution
2. Integration test execution
3. Performance testing
4. Load testing
5. Security testing
6. Regression testing

**Phase 5: Documentation & Deployment (1 week)**
1. Update documentation
2. Update deployment scripts
3. Create rollback plan
4. Train team
5. Staged deployment
6. Monitor production

**Total Timeline: 6-7 weeks**

### 7.2 Alternative: Option 3 (Play 3.0 + Pekko)

**Additional Phases:**
- Play 2.9 → 3.0 migration (3-4 weeks)
- Package rename updates
- Configuration format updates
- Template updates
- Additional testing

**Total Timeline: 10-12 weeks**

---

## 8. Detailed Issues & Drawbacks

### 8.1 Play 2.9 + Pekko Issues

1. **Play-Pekko Integration**
   - No official Play 2.9 Pekko support
   - Requires community library or custom code
   - Example: Create custom `PekkoGuiceSupport` trait
   - May be unstable or incomplete

2. **Limited Future Support**
   - Play 2.9.x in maintenance mode
   - Eventually need to upgrade to Play 3.0 anyway
   - Double migration effort

3. **Dependency Conflicts**
   - Some Play 2.9 modules may still reference Akka
   - Need careful exclusion management
   - Potential runtime issues

### 8.2 Play 3.0 + Pekko Issues

1. **Breaking Changes**
   - Extensive API changes
   - Package renames
   - Configuration format changes
   - Routing DSL changes
   - More testing required

2. **Learning Curve**
   - New APIs to learn
   - Updated patterns
   - Team training required

3. **Third-party Library Compatibility**
   - Some libraries may not support Play 3.0 yet
   - May need alternatives or custom wrappers
   - Example: Current play2-maven-plugin version?

### 8.3 General Migration Drawbacks

1. **Development Time**
   - 6-12 weeks depending on approach
   - Feature development paused
   - Resource allocation needed

2. **Testing Burden**
   - Extensive regression testing
   - Performance validation
   - All actor interactions must be verified

3. **Risk of Regression**
   - Complex async code
   - Subtle behavior changes
   - Hard-to-test scenarios

4. **Documentation Overhead**
   - Update all docs
   - Create migration guides
   - Train team members

5. **Deployment Risk**
   - New dependencies
   - Configuration changes
   - Potential production issues

---

## 9. Tooling & Automation

### 9.1 Automated Migration Tools

**Package Rename Tool:**
```bash
# Use sed for bulk rename
find . -type f -name "*.java" -exec sed -i 's/import akka\./import org.apache.pekko./g' {} +
find . -type f -name "*.java" -exec sed -i 's/import com\.typesafe\.akka/import org.apache.pekko/g' {} +

# Configuration files
find . -type f -name "*.conf" -exec sed -i 's/akka\./pekko./g' {} +
find . -type f -name "*.conf" -exec sed -i 's/akka {/pekko {/g' {} +
```

**Maven Dependency Update:**
```xml
<!-- Use versions-maven-plugin -->
mvn versions:use-latest-versions -DallowMajorUpdates=false
```

### 9.2 Testing Strategy

1. **Unit Tests:**
   - Existing unit tests should pass unchanged
   - Test actor behavior
   - Test message handling

2. **Integration Tests:**
   - Test actor communication
   - Test HTTP request handling
   - Test async flows

3. **Performance Tests:**
   - Throughput testing
   - Latency testing
   - Load testing
   - Compare before/after metrics

4. **Compatibility Tests:**
   - Serialization compatibility
   - Configuration compatibility
   - API compatibility

### 9.3 Migration Checklist

**Pre-Migration:**
- [ ] Backup current codebase
- [ ] Document current architecture
- [ ] Create comprehensive test suite
- [ ] Set up CI/CD for migration branch
- [ ] Identify all Akka usages
- [ ] Review third-party dependencies
- [ ] Create rollback plan

**During Migration:**
- [ ] Update Maven POMs
- [ ] Run package rename automation
- [ ] Update configuration files
- [ ] Update import statements
- [ ] Fix compilation errors
- [ ] Update test utilities
- [ ] Run all tests
- [ ] Performance testing
- [ ] Security scanning

**Post-Migration:**
- [ ] Update documentation
- [ ] Update README
- [ ] Update deployment guides
- [ ] Train team
- [ ] Monitor production
- [ ] Collect metrics
- [ ] Review and optimize

---

## 10. Recommendations

### 10.1 Short-term Recommendation (Next 6-12 months)

**Recommended: Option 2 - Play 2.9 + Pekko 1.0**

**Rationale:**
1. Resolves Akka licensing issue immediately
2. Moderate effort (6-7 weeks)
3. Lower risk than Play 3.0 jump
4. API-compatible migration
5. Buys time to plan Play 3.0 migration

**Action Items:**
1. Allocate 6-7 weeks for migration
2. Create dedicated migration team
3. Set up test environment
4. Start with dependency updates
5. Implement automated testing
6. Plan staged rollout

### 10.2 Long-term Recommendation (12-24 months)

**Recommended: Migrate to Play 3.0 + Pekko**

**Rationale:**
1. Future-proof solution
2. Official Pekko support
3. Latest features and security
4. Long-term support
5. Better ecosystem alignment

**Action Items:**
1. Plan after Play 2.9 + Pekko stabilizes
2. Allocate 10-12 weeks
3. Modern Java (17/21) adoption
4. Scala 2.13/3.x evaluation
5. Consider SBT migration

### 10.3 Key Success Factors

1. **Comprehensive Testing**
   - Don't rush the migration
   - Test all actor interactions
   - Performance validation critical

2. **Incremental Approach**
   - Don't try to do everything at once
   - Play 2.9 first, then 3.0 later
   - Learn from each phase

3. **Team Alignment**
   - Get buy-in from all stakeholders
   - Allocate dedicated resources
   - Don't do this while developing new features

4. **Monitoring & Rollback**
   - Have a rollback plan
   - Monitor closely after deployment
   - Be ready to revert if issues arise

5. **Documentation**
   - Document everything
   - Create runbooks
   - Share knowledge with team

---

## 11. Cost-Benefit Analysis

### 11.1 Costs

**Development Effort:**
- Play 2.9 + Pekko: 6-7 weeks × team size
- Play 3.0 + Pekko: 10-12 weeks × team size

**Testing Effort:**
- Regression testing: 2-3 weeks
- Performance validation: 1 week
- Security testing: 1 week

**Risk Costs:**
- Potential production issues
- Rollback scenarios
- Support overhead

**Opportunity Cost:**
- Delayed feature development
- Resource allocation

**Total Estimated Cost:**
- Option 2: 8-10 weeks of development time
- Option 3: 14-16 weeks of development time

### 11.2 Benefits

**License Compliance:**
- Avoid Akka BSL licensing fees: $$$$ (enterprise scale)
- Legal risk mitigation: Priceless
- Open-source compliance: Critical

**Technical:**
- Security updates: Ongoing
- Performance improvements: 5-10% potential
- Modern features: Ongoing value
- Reduced technical debt: Long-term

**Business:**
- No vendor lock-in
- Community support
- Competitive advantage
- Future flexibility

**ROI:**
- Break-even: 6-12 months
- Long-term value: Significant
- Risk avoidance: Critical

### 11.3 Recommendation

**The migration is NECESSARY and RECOMMENDED.**

The Akka license change makes this migration mandatory for any production deployment. The question is not "if" but "when" and "how".

**Start with Option 2 (Play 2.9 + Pekko) immediately:**
- Resolves legal/licensing issues
- Moderate effort
- Lower risk
- Establishes Pekko foundation

**Plan Option 3 (Play 3.0) for future:**
- After Option 2 stabilizes
- Long-term modernization
- Full benefit realization

---

## 12. References & Resources

### 12.1 Official Documentation

**Apache Pekko:**
- https://pekko.apache.org/
- https://pekko.apache.org/docs/pekko/current/
- https://github.com/apache/pekko

**Play Framework:**
- https://www.playframework.com/documentation/2.9.x/Home
- https://www.playframework.com/documentation/3.0.x/Home
- https://github.com/playframework/playframework

**Akka to Pekko Migration:**
- https://pekko.apache.org/docs/pekko/current/project/migration-guides.html
- https://pekko.apache.org/docs/pekko/current/project/migration-guide-1.0.x.html

### 12.2 Community Resources

**Play + Pekko Integration:**
- https://github.com/playframework/play-samples (for Play 3.0)
- Community forums and discussions

**Migration Experiences:**
- Search for "Akka to Pekko migration" case studies
- Apache mailing lists
- Stack Overflow

### 12.3 Tools

**Dependency Management:**
- Maven Versions Plugin: https://www.mojohaus.org/versions-maven-plugin/
- Dependency analysis tools

**Testing:**
- Apache JMeter for load testing
- Gatling for performance testing

**Automation:**
- Shell scripts for bulk renaming
- IntelliJ IDEA refactoring tools
- sed/awk for text processing

---

## 13. Conclusion

The migration from Akka to Apache Pekko is **essential** due to Akka's license change. The userorg-service repository has significant Akka integration (128 files, 60+ actors) but benefits from Pekko's API compatibility.

**Key Takeaways:**

1. **The migration is mandatory** - Akka's BSL license makes continued use problematic
2. **Pekko is the clear successor** - API-compatible, Apache-backed, open-source
3. **Two-phase approach recommended**:
   - Phase 1 (Now): Play 2.9 + Pekko (6-7 weeks)
   - Phase 2 (Future): Play 3.0 + Pekko (10-12 weeks total)
4. **Risks are manageable** - Comprehensive testing mitigates most issues
5. **Benefits outweigh costs** - License compliance, future-proofing, community support

**Next Steps:**

1. Get stakeholder approval
2. Allocate dedicated team (6-7 weeks)
3. Start with Play 2.9 + Pekko migration
4. Follow phased approach outlined in this report
5. Plan Play 3.0 upgrade for future

This migration is an investment in the long-term health and sustainability of the userorg-service project.

---

**Report Version:** 1.0  
**Date:** 2025-01-07  
**Status:** Draft for Review
