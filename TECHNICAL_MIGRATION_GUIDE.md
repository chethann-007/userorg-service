# Technical Migration Guide: Akka to Pekko

## Document Purpose

This guide provides specific technical details, code examples, and step-by-step instructions for migrating the userorg-service from Akka to Apache Pekko. Use this alongside the main MIGRATION_COMPATIBILITY_REPORT.md.

---

## 1. Affected Files Analysis

### 1.1 Complete File List by Module

**Core Module - actor-core (1 file):**
```
core/actor-core/src/main/java/org/sunbird/actor/core/BaseActor.java
```

**Core Module - platform-common:**
```
core/platform-common/src/main/java/org/sunbird/util/ProjectUtil.java (uses ActorSystem)
```

**Service Module - Main Actors (20+ files):**
```
service/src/main/java/org/sunbird/actor/
├── BackgroundJobManager.java
├── bulkupload/
│   ├── BaseBulkUploadActor.java
│   ├── BaseBulkUploadBackgroundJobActor.java
│   ├── BulkUploadManagementActor.java
│   ├── LocationBulkUploadActor.java
│   ├── LocationBulkUploadBackGroundJobActor.java
│   ├── OrgBulkUploadActor.java
│   └── UserBulkUploadBackgroundJobActor.java
├── feed/
│   └── UserFeedActor.java
├── fileuploadservice/
│   └── FileUploadServiceActor.java
├── health/
│   └── HealthActor.java
├── location/
│   ├── BaseLocationActor.java
│   ├── LocationActor.java
│   └── LocationBackgroundActor.java
├── notes/
│   └── NotesManagementActor.java
├── organisation/
│   ├── OrganisationBackgroundActor.java
│   └── OrganisationManagementActor.java
├── otp/
│   ├── OTPActor.java
│   └── SendOTPActor.java
├── search/
│   └── SearchHandlerActor.java
├── sync/
│   ├── EsSyncActor.java
│   └── EsSyncBackgroundActor.java
├── systemsettings/
│   └── SystemSettingsActor.java
├── user/
│   ├── UserManagementActor.java
│   ├── UserProfileReadActor.java
│   ├── UserRoleActor.java
│   ├── UserStatusActor.java
│   └── UserTypeActor.java
└── userconsent/
    └── UserConsentActor.java
```

**Controller Module (6 files):**
```
controller/app/
├── controllers/
│   └── BaseController.java
├── modules/
│   ├── ActorStartModule.java
│   ├── ApplicationStart.java
│   ├── OnRequestHandler.java
│   └── SignalHandler.java
└── util/
    └── ACTORS.java
```

**Test Files (40+ files):**
- All files in `service/src/test/java/` using `akka.testkit`
- All files using `akka.dispatch.Futures` for mocking

---

## 2. Dependency Migration Details

### 2.1 Root POM (pom.xml)

**No Changes Required** - This is just the parent POM.

### 2.2 Core/actor-core POM

**File:** `core/actor-core/pom.xml`

**Current:**
```xml
<properties>
    <typesafe.akka.version>2.5.22</typesafe.akka.version>
</properties>

<dependencies>
    <dependency>
        <groupId>com.typesafe.akka</groupId>
        <artifactId>akka-actor_${scala.major.version}</artifactId>
        <version>${typesafe.akka.version}</version>
    </dependency>
    <dependency>
        <groupId>com.typesafe.akka</groupId>
        <artifactId>akka-slf4j_${scala.major.version}</artifactId>
        <version>${typesafe.akka.version}</version>
    </dependency>
    <dependency>
        <groupId>com.typesafe.akka</groupId>
        <artifactId>akka-remote_${scala.major.version}</artifactId>
        <version>${typesafe.akka.version}</version>
    </dependency>
</dependencies>
```

**Updated for Pekko:**
```xml
<properties>
    <pekko.version>1.0.2</pekko.version>
    <scala.major.version>2.13</scala.major.version>
</properties>

<dependencies>
    <dependency>
        <groupId>org.apache.pekko</groupId>
        <artifactId>pekko-actor_${scala.major.version}</artifactId>
        <version>${pekko.version}</version>
    </dependency>
    <dependency>
        <groupId>org.apache.pekko</groupId>
        <artifactId>pekko-slf4j_${scala.major.version}</artifactId>
        <version>${pekko.version}</version>
    </dependency>
    <dependency>
        <groupId>org.apache.pekko</groupId>
        <artifactId>pekko-remote_${scala.major.version}</artifactId>
        <version>${pekko.version}</version>
    </dependency>
</dependencies>
```

### 2.3 Core/platform-common POM

**File:** `core/platform-common/pom.xml`

**Current:**
```xml
<properties>
    <typesafe.akka.version>2.5.22</typesafe.akka.version>
</properties>

<dependency>
    <groupId>com.typesafe.akka</groupId>
    <artifactId>akka-slf4j_${scala.major.version}</artifactId>
    <version>${typesafe.akka.version}</version>
</dependency>
```

**Updated for Pekko:**
```xml
<properties>
    <pekko.version>1.0.2</pekko.version>
</properties>

<dependency>
    <groupId>org.apache.pekko</groupId>
    <artifactId>pekko-slf4j_${scala.major.version}</artifactId>
    <version>${pekko.version}</version>
</dependency>
```

### 2.4 Service Module POM

**File:** `service/pom.xml`

**Current:**
```xml
<properties>
    <typesafe.akka.version>2.5.22</typesafe.akka.version>
</properties>

<dependency>
    <groupId>com.typesafe.akka</groupId>
    <artifactId>akka-testkit_${scala.major.version}</artifactId>
    <version>${typesafe.akka.version}</version>
    <scope>test</scope>
</dependency>
```

**Updated for Pekko:**
```xml
<properties>
    <pekko.version>1.0.2</pekko.version>
</properties>

<dependency>
    <groupId>org.apache.pekko</groupId>
    <artifactId>pekko-testkit_${scala.major.version}</artifactId>
    <version>${pekko.version}</version>
    <scope>test</scope>
</dependency>
```

### 2.5 Controller Module POM

**File:** `controller/pom.xml`

**Current:**
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
    <scope>test</scope>
</dependency>

<dependency>
    <groupId>com.typesafe.play</groupId>
    <artifactId>play-akka-http-server_${scala.major.version}</artifactId>
    <version>${play2.version}</version>
</dependency>
```

**Updated for Play 2.9 + Pekko:**
```xml
<properties>
    <play2.version>2.9.3</play2.version>
    <pekko.version>1.0.2</pekko.version>
    <scala.major.version>2.13</scala.major.version>
</properties>

<dependency>
    <groupId>com.typesafe.play</groupId>
    <artifactId>play-guice_${scala.major.version}</artifactId>
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
    <scope>test</scope>
</dependency>

<!-- For Play 2.9, we need Play-Pekko HTTP server -->
<!-- Note: This might require community library or custom integration -->
<dependency>
    <groupId>org.playframework</groupId>
    <artifactId>play-pekko-http-server_${scala.major.version}</artifactId>
    <version>${play2.version}</version>
</dependency>

<!-- Alternatively, stay with Akka HTTP and only migrate actors -->
<!-- This is a transitional approach -->
<dependency>
    <groupId>com.typesafe.play</groupId>
    <artifactId>play-akka-http-server_${scala.major.version}</artifactId>
    <version>${play2.version}</version>
    <exclusions>
        <exclusion>
            <groupId>com.typesafe.akka</groupId>
            <artifactId>*</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

---

## 3. Code Migration Examples

### 3.1 BaseActor Migration

**File:** `core/actor-core/src/main/java/org/sunbird/actor/core/BaseActor.java`

**Before:**
```java
package org.sunbird.actor.core;

import akka.actor.UntypedAbstractActor;
import org.sunbird.exception.ProjectCommonException;
import org.sunbird.exception.ResponseCode;
import org.sunbird.logging.LoggerUtil;
import org.sunbird.operations.ActorOperations;
import org.sunbird.request.Request;

public abstract class BaseActor extends UntypedAbstractActor {
  public final LoggerUtil logger = new LoggerUtil(this.getClass());

  public abstract void onReceive(Request request) throws Throwable;

  @Override
  public void onReceive(Object message) throws Throwable {
    if (message instanceof Request) {
      Request request = (Request) message;
      String operation = request.getOperation();
      try {
        onReceive(request);
      } catch (Exception e) {
        logger.error(
            request.getRequestContext(),
            "Error while processing the message for operation: " + operation,
            e);
        if (e instanceof ProjectCommonException) {
          ProjectCommonException exception =
              new ProjectCommonException(
                  (ProjectCommonException) e,
                  ActorOperations.getOperationCodeByActorOperation(request.getOperation()));
          sender().tell(exception, self());
        }
        sender().tell(e, self());
      }
    }
  }

  protected void onReceiveUnsupportedOperation() {
    ProjectCommonException exception =
        new ProjectCommonException(
            ResponseCode.invalidOperationName,
            ResponseCode.invalidOperationName.getErrorMessage(),
            ResponseCode.CLIENT_ERROR.getResponseCode());
    sender().tell(exception, self());
  }
}
```

**After (Pekko):**
```java
package org.sunbird.actor.core;

import org.apache.pekko.actor.UntypedAbstractActor;
import org.sunbird.exception.ProjectCommonException;
import org.sunbird.exception.ResponseCode;
import org.sunbird.logging.LoggerUtil;
import org.sunbird.operations.ActorOperations;
import org.sunbird.request.Request;

public abstract class BaseActor extends UntypedAbstractActor {
  // NO OTHER CHANGES - Implementation remains identical!
  public final LoggerUtil logger = new LoggerUtil(this.getClass());

  public abstract void onReceive(Request request) throws Throwable;

  @Override
  public void onReceive(Object message) throws Throwable {
    if (message instanceof Request) {
      Request request = (Request) message;
      String operation = request.getOperation();
      try {
        onReceive(request);
      } catch (Exception e) {
        logger.error(
            request.getRequestContext(),
            "Error while processing the message for operation: " + operation,
            e);
        if (e instanceof ProjectCommonException) {
          ProjectCommonException exception =
              new ProjectCommonException(
                  (ProjectCommonException) e,
                  ActorOperations.getOperationCodeByActorOperation(request.getOperation()));
          sender().tell(exception, self());
        }
        sender().tell(e, self());
      }
    }
  }

  protected void onReceiveUnsupportedOperation() {
    ProjectCommonException exception =
        new ProjectCommonException(
            ResponseCode.invalidOperationName,
            ResponseCode.invalidOperationName.getErrorMessage(),
            ResponseCode.CLIENT_ERROR.getResponseCode());
    sender().tell(exception, self());
  }
}
```

**Changes:** Only the import statement changes. All logic remains the same.

### 3.2 Controller Migration

**File:** `controller/app/controllers/BaseController.java`

**Before:**
```java
package controllers;

import akka.actor.ActorRef;
import akka.actor.ActorSelection;
import akka.pattern.PatternsCS;
import akka.util.Timeout;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.TimeUnit;
import play.mvc.Controller;
import play.mvc.Http.Request;
import play.mvc.Result;

public class BaseController extends Controller {
  
  public CompletionStage<Result> actorResponseHandler(
      Object actorRef,
      org.sunbird.request.Request request,
      Timeout timeout,
      String responseKey,
      Request httpReq) {
    
    Function<Object, Result> function =
        result -> {
          if (result instanceof Response) {
            Response response = (Response) result;
            Result reslt = createCommonResponse(response, responseKey, httpReq);
            return reslt;
          }
          return null;
        };

    if (actorRef instanceof ActorRef) {
      return PatternsCS.ask((ActorRef) actorRef, request, timeout).thenApplyAsync(function);
    } else {
      return PatternsCS.ask((ActorSelection) actorRef, request, timeout).thenApplyAsync(function);
    }
  }
}
```

**After (Pekko):**
```java
package controllers;

import org.apache.pekko.actor.ActorRef;
import org.apache.pekko.actor.ActorSelection;
import org.apache.pekko.pattern.PatternsCS;
import org.apache.pekko.util.Timeout;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.TimeUnit;
import play.mvc.Controller;
import play.mvc.Http.Request;
import play.mvc.Result;

public class BaseController extends Controller {
  
  // NO OTHER CHANGES - Implementation remains identical!
  public CompletionStage<Result> actorResponseHandler(
      Object actorRef,
      org.sunbird.request.Request request,
      Timeout timeout,
      String responseKey,
      Request httpReq) {
    
    Function<Object, Result> function =
        result -> {
          if (result instanceof Response) {
            Response response = (Response) result;
            Result reslt = createCommonResponse(response, responseKey, httpReq);
            return reslt;
          }
          return null;
        };

    if (actorRef instanceof ActorRef) {
      return PatternsCS.ask((ActorRef) actorRef, request, timeout).thenApplyAsync(function);
    } else {
      return PatternsCS.ask((ActorSelection) actorRef, request, timeout).thenApplyAsync(function);
    }
  }
}
```

### 3.3 Actor Module Migration

**File:** `controller/app/modules/ActorStartModule.java`

**Before:**
```java
package modules;

import akka.routing.FromConfig;
import akka.routing.RouterConfig;
import com.google.inject.AbstractModule;
import org.sunbird.logging.LoggerUtil;
import play.libs.akka.AkkaGuiceSupport;
import util.ACTORS;

public class ActorStartModule extends AbstractModule implements AkkaGuiceSupport {
  private static LoggerUtil logger = new LoggerUtil(ActorStartModule.class);

  @Override
  protected void configure() {
    logger.debug("binding actors for dependency injection");
    final RouterConfig config = new FromConfig();
    for (ACTORS actor : ACTORS.values()) {
      bindActor(actor.getActorClass(), actor.getActorName(), props -> props.withRouter(config));
    }
    logger.debug("binding completed");
  }
}
```

**After (Pekko) - Play 2.9:**
```java
package modules;

import org.apache.pekko.routing.FromConfig;
import org.apache.pekko.routing.RouterConfig;
import com.google.inject.AbstractModule;
import org.sunbird.logging.LoggerUtil;
// For Play 2.9: Need custom integration or community library
import play.libs.pekko.PekkoGuiceSupport; // This may not exist!
import util.ACTORS;

public class ActorStartModule extends AbstractModule implements PekkoGuiceSupport {
  private static LoggerUtil logger = new LoggerUtil(ActorStartModule.class);

  @Override
  protected void configure() {
    logger.debug("binding actors for dependency injection");
    final RouterConfig config = new FromConfig();
    for (ACTORS actor : ACTORS.values()) {
      bindActor(actor.getActorClass(), actor.getActorName(), props -> props.withRouter(config));
    }
    logger.debug("binding completed");
  }
}
```

**Note:** For Play 2.9, `play.libs.pekko.PekkoGuiceSupport` may not exist. You might need to:
1. Use a community library
2. Create custom binding logic
3. Or jump directly to Play 3.0

**After (Pekko) - Play 3.0:**
```java
package modules;

import org.apache.pekko.routing.FromConfig;
import org.apache.pekko.routing.RouterConfig;
import com.google.inject.AbstractModule;
import org.sunbird.logging.LoggerUtil;
import org.playframework.pekko.PekkoGuiceSupport; // Official in Play 3.0
import util.ACTORS;

public class ActorStartModule extends AbstractModule implements PekkoGuiceSupport {
  private static LoggerUtil logger = new LoggerUtil(ActorStartModule.class);

  @Override
  protected void configure() {
    logger.debug("binding actors for dependency injection");
    final RouterConfig config = new FromConfig();
    for (ACTORS actor : ACTORS.values()) {
      bindActor(actor.getActorClass(), actor.getActorName(), props -> props.withRouter(config));
    }
    logger.debug("binding completed");
  }
}
```

### 3.4 Signal Handler Migration

**File:** `controller/app/modules/SignalHandler.java`

**Before:**
```java
package modules;

import akka.actor.ActorSystem;
import java.util.concurrent.TimeUnit;
import javax.inject.Inject;
import javax.inject.Provider;
import javax.inject.Singleton;
import org.sunbird.logging.LoggerUtil;
import scala.concurrent.duration.Duration;
import scala.concurrent.duration.FiniteDuration;

@Singleton
public class SignalHandler {
  
  @Inject
  public SignalHandler(ActorSystem actorSystem, Provider<Application> application) {
    // Implementation
  }
}
```

**After (Pekko):**
```java
package modules;

import org.apache.pekko.actor.ActorSystem;
import java.util.concurrent.TimeUnit;
import javax.inject.Inject;
import javax.inject.Provider;
import javax.inject.Singleton;
import org.sunbird.logging.LoggerUtil;
import scala.concurrent.duration.Duration;
import scala.concurrent.duration.FiniteDuration;

@Singleton
public class SignalHandler {
  
  @Inject
  public SignalHandler(ActorSystem actorSystem, Provider<Application> application) {
    // NO CHANGES to implementation
  }
}
```

### 3.5 Test File Migration

**File:** `service/src/test/java/org/sunbird/actor/health/HealthActorTest.java`

**Before:**
```java
package org.sunbird.actor.health;

import static akka.testkit.JavaTestKit.duration;

import akka.actor.ActorRef;
import akka.actor.ActorSystem;
import akka.actor.Props;
import akka.dispatch.Futures;
import akka.testkit.javadsl.TestKit;
import org.junit.BeforeClass;
import org.junit.Test;

public class HealthActorTest {
  private static ActorSystem system;
  
  @BeforeClass
  public static void setUp() {
    system = ActorSystem.create("system");
  }
  
  @Test
  public void getHealthCheck() {
    TestKit probe = new TestKit(system);
    ActorRef subject = system.actorOf(Props.create(HealthActor.class));
    
    subject.tell(request, probe.getRef());
    probe.expectMsgClass(duration("10 seconds"), Response.class);
  }
}
```

**After (Pekko):**
```java
package org.sunbird.actor.health;

import static org.apache.pekko.testkit.javadsl.TestKit.duration;

import org.apache.pekko.actor.ActorRef;
import org.apache.pekko.actor.ActorSystem;
import org.apache.pekko.actor.Props;
import org.apache.pekko.dispatch.Futures;
import org.apache.pekko.testkit.javadsl.TestKit;
import org.junit.BeforeClass;
import org.junit.Test;

public class HealthActorTest {
  private static ActorSystem system;
  
  @BeforeClass
  public static void setUp() {
    system = ActorSystem.create("system");
  }
  
  @Test
  public void getHealthCheck() {
    TestKit probe = new TestKit(system);
    ActorRef subject = system.actorOf(Props.create(HealthActor.class));
    
    subject.tell(request, probe.getRef());
    probe.expectMsgClass(duration("10 seconds"), Response.class);
  }
}
```

---

## 4. Configuration Migration

### 4.1 application.conf Changes

**File:** `controller/conf/application.conf`

**Before (Lines 8-400+):**
```hocon
## Akka
# https://www.playframework.com/documentation/latest/JavaAkka#Configuration
# ~~~~~
akka {
  stdout-loglevel = "OFF"
  loglevel = "OFF"
  jvm-exit-on-fatal-error = off
  log-config-on-start = off
  actor {
    provider = "akka.actor.LocalActorRefProvider"
    serializers {
      java = "akka.serialization.JavaSerializer"
    }
    serialization-bindings {
      "org.sunbird.request.Request" = java
      "org.sunbird.response.Response" = java
    }
    default-dispatcher {
      fork-join-executor {
        parallelism-min = 8
        parallelism-factor = 32.0
        parallelism-max = 64
        task-peeking-mode = "FIFO"
      }
    }
    rr-usr-dispatcher {
      type = "Dispatcher"
      executor = "fork-join-executor"
      fork-join-executor {
        parallelism-min = 8
        parallelism-factor = 32.0
        parallelism-max = 64
      }
      throughput = 1
    }
    # ... many more dispatchers
    deployment {
      "/health_actor" {
        router = smallest-mailbox-pool
        nr-of-instances = 2
        dispatcher = health-check-dispatcher
      }
      "/health_actor/*" {
        dispatcher = akka.actor.health-check-dispatcher
      }
      # ... many more actor deployments
    }
  }
}
```

**After (Pekko):**
```hocon
## Pekko (formerly Akka)
# https://pekko.apache.org/docs/pekko/current/
# ~~~~~
pekko {
  stdout-loglevel = "OFF"
  loglevel = "OFF"
  jvm-exit-on-fatal-error = off
  log-config-on-start = off
  actor {
    provider = "org.apache.pekko.actor.LocalActorRefProvider"
    serializers {
      java = "org.apache.pekko.serialization.JavaSerializer"
    }
    serialization-bindings {
      "org.sunbird.request.Request" = java
      "org.sunbird.response.Response" = java
    }
    default-dispatcher {
      fork-join-executor {
        parallelism-min = 8
        parallelism-factor = 32.0
        parallelism-max = 64
        task-peeking-mode = "FIFO"
      }
    }
    rr-usr-dispatcher {
      type = "Dispatcher"
      executor = "fork-join-executor"
      fork-join-executor {
        parallelism-min = 8
        parallelism-factor = 32.0
        parallelism-max = 64
      }
      throughput = 1
    }
    # ... many more dispatchers (same config)
    deployment {
      "/health_actor" {
        router = smallest-mailbox-pool
        nr-of-instances = 2
        dispatcher = health-check-dispatcher
      }
      "/health_actor/*" {
        dispatcher = pekko.actor.health-check-dispatcher  # Note: pekko prefix
      }
      # ... many more actor deployments
    }
  }
}
```

**Key Changes:**
1. Top-level `akka` → `pekko`
2. `akka.actor.LocalActorRefProvider` → `org.apache.pekko.actor.LocalActorRefProvider`
3. `akka.serialization.JavaSerializer` → `org.apache.pekko.serialization.JavaSerializer`
4. Dispatcher references: `akka.actor.*` → `pekko.actor.*`

### 4.2 Automated Configuration Migration Script

```bash
#!/bin/bash
# migrate-config.sh

CONF_FILE="controller/conf/application.conf"
BACKUP_FILE="${CONF_FILE}.backup"

# Backup original
cp "$CONF_FILE" "$BACKUP_FILE"

# Replace akka with pekko
sed -i 's/^akka {/pekko {/' "$CONF_FILE"
sed -i 's/"akka\.actor\.LocalActorRefProvider"/"org.apache.pekko.actor.LocalActorRefProvider"/' "$CONF_FILE"
sed -i 's/"akka\.serialization\.JavaSerializer"/"org.apache.pekko.serialization.JavaSerializer"/' "$CONF_FILE"
sed -i 's/akka\.actor\./pekko.actor./g' "$CONF_FILE"

# Note: This is a basic script. Manual review required!
echo "Configuration migrated. Please review changes manually."
echo "Original backup: $BACKUP_FILE"
```

---

## 5. Migration Script

### 5.1 Complete Automated Migration Script

```bash
#!/bin/bash
# migrate-to-pekko.sh
# 
# This script automates the migration from Akka to Pekko
# Review all changes before committing!

set -e

echo "========================================="
echo "Akka to Pekko Migration Script"
echo "========================================="
echo ""

# Backup
echo "Creating backup..."
BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r core service controller "$BACKUP_DIR/"
echo "Backup created in $BACKUP_DIR"
echo ""

# Java source files - Import statements
echo "Migrating Java import statements..."

# Core imports
find . -type f -name "*.java" -exec sed -i \
    's/import akka\./import org.apache.pekko./g' {} +

find . -type f -name "*.java" -exec sed -i \
    's/import com\.typesafe\.akka/import org.apache.pekko/g' {} +

# Specific static imports
find . -type f -name "*.java" -exec sed -i \
    's/import static akka\./import static org.apache.pekko./g' {} +

echo "Java imports migrated."
echo ""

# Configuration files
echo "Migrating configuration files..."

# application.conf
if [ -f "controller/conf/application.conf" ]; then
    cp controller/conf/application.conf controller/conf/application.conf.backup
    
    # Top-level akka block
    sed -i 's/^akka {/pekko {/' controller/conf/application.conf
    
    # Provider
    sed -i 's/"akka\.actor\.LocalActorRefProvider"/"org.apache.pekko.actor.LocalActorRefProvider"/' \
        controller/conf/application.conf
    
    # Serializers
    sed -i 's/"akka\.serialization\.JavaSerializer"/"org.apache.pekko.serialization.JavaSerializer"/' \
        controller/conf/application.conf
    
    # Dispatcher references
    sed -i 's/dispatcher = akka\.actor\./dispatcher = pekko.actor./g' \
        controller/conf/application.conf
fi

echo "Configuration files migrated."
echo ""

# POM files
echo "NOTE: POM files require manual migration!"
echo "Please update the following files manually:"
echo "  - core/actor-core/pom.xml"
echo "  - core/platform-common/pom.xml"
echo "  - service/pom.xml"
echo "  - controller/pom.xml"
echo ""
echo "Replace:"
echo "  com.typesafe.akka -> org.apache.pekko"
echo "  \${typesafe.akka.version} -> \${pekko.version}"
echo "  And update version to 1.0.2"
echo ""

# Summary
echo "========================================="
echo "Migration Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Review all changes: git diff"
echo "2. Manually update POM files"
echo "3. Update Play Framework version (if applicable)"
echo "4. Build: mvn clean install"
echo "5. Run tests: mvn test"
echo "6. Review and commit"
echo ""
echo "Backup location: $BACKUP_DIR"
```

### 5.2 Verification Script

```bash
#!/bin/bash
# verify-migration.sh
#
# Verifies that all Akka references have been migrated to Pekko

echo "Checking for remaining Akka references..."
echo ""

# Check Java files
echo "=== Java Files ==="
AKKA_IMPORTS=$(grep -r "import akka\." --include="*.java" . | wc -l)
AKKA_TYPESAFE=$(grep -r "import com\.typesafe\.akka" --include="*.java" . | wc -l)

echo "Remaining Akka imports: $AKKA_IMPORTS"
echo "Remaining Typesafe Akka imports: $AKKA_TYPESAFE"

if [ $AKKA_IMPORTS -gt 0 ]; then
    echo "Files with Akka imports:"
    grep -r "import akka\." --include="*.java" . | cut -d: -f1 | sort | uniq
fi

if [ $AKKA_TYPESAFE -gt 0 ]; then
    echo "Files with Typesafe Akka imports:"
    grep -r "import com\.typesafe\.akka" --include="*.java" . | cut -d: -f1 | sort | uniq
fi

echo ""

# Check configuration files
echo "=== Configuration Files ==="
AKKA_CONF=$(grep -r "^akka {" --include="*.conf" . | wc -l)
echo "Remaining 'akka {' blocks: $AKKA_CONF"

if [ $AKKA_CONF -gt 0 ]; then
    grep -r "^akka {" --include="*.conf" .
fi

echo ""

# Check POM files
echo "=== POM Files ==="
AKKA_DEPS=$(grep -r "com\.typesafe\.akka" --include="pom.xml" . | wc -l)
echo "Remaining Akka dependencies: $AKKA_DEPS"

if [ $AKKA_DEPS -gt 0 ]; then
    echo "Files with Akka dependencies:"
    grep -r "com\.typesafe\.akka" --include="pom.xml" . | cut -d: -f1 | sort | uniq
    echo ""
    echo "These need manual update to org.apache.pekko"
fi

echo ""
echo "=== Summary ==="
if [ $AKKA_IMPORTS -eq 0 ] && [ $AKKA_TYPESAFE -eq 0 ] && [ $AKKA_CONF -eq 0 ]; then
    echo "✓ Source code migration complete!"
else
    echo "✗ Source code still has Akka references"
fi

if [ $AKKA_DEPS -eq 0 ]; then
    echo "✓ Dependencies migrated!"
else
    echo "✗ POM files need manual update"
fi
```

---

## 6. Testing Strategy

### 6.1 Pre-Migration Test Suite

Run before migration to establish baseline:

```bash
#!/bin/bash
# pre-migration-test.sh

echo "Running pre-migration tests..."

# Unit tests
mvn test -pl service

# Integration tests (if any)
mvn verify -pl controller

# Capture coverage
mvn clean test jacoco:report

# Save results
mkdir -p test-results/pre-migration
cp -r target/surefire-reports/* test-results/pre-migration/
cp -r target/site/jacoco/* test-results/pre-migration/coverage/

echo "Pre-migration test results saved to test-results/pre-migration/"
```

### 6.2 Post-Migration Test Suite

Run after migration to verify:

```bash
#!/bin/bash
# post-migration-test.sh

echo "Running post-migration tests..."

# Clean and build
mvn clean install -DskipTests

# Unit tests
mvn test -pl service

# Integration tests
mvn verify -pl controller

# Capture coverage
mvn jacoco:report

# Save results
mkdir -p test-results/post-migration
cp -r target/surefire-reports/* test-results/post-migration/
cp -r target/site/jacoco/* test-results/post-migration/coverage/

echo "Post-migration test results saved to test-results/post-migration/"

# Compare
echo ""
echo "Comparing results..."
diff -r test-results/pre-migration/surefire-reports test-results/post-migration/surefire-reports || true
```

### 6.3 Actor-Specific Tests

Create tests for each actor:

```java
// Example: OrganisationManagementActorTest.java
import org.apache.pekko.actor.ActorRef;
import org.apache.pekko.actor.ActorSystem;
import org.apache.pekko.actor.Props;
import org.apache.pekko.testkit.javadsl.TestKit;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import scala.concurrent.duration.Duration;
import java.util.concurrent.TimeUnit;

public class OrganisationManagementActorTest {
    static ActorSystem system;

    @BeforeClass
    public static void setup() {
        system = ActorSystem.create();
    }

    @AfterClass
    public static void teardown() {
        TestKit.shutdownActorSystem(system);
        system = null;
    }

    @Test
    public void testCreateOrganisation() {
        new TestKit(system) {{
            final ActorRef orgActor = system.actorOf(
                Props.create(OrganisationManagementActor.class));

            Request request = new Request();
            request.setOperation("createOrg");
            // ... set request data

            orgActor.tell(request, getRef());

            Response response = expectMsgClass(
                Duration.create(10, TimeUnit.SECONDS),
                Response.class);

            assertEquals(ResponseCode.OK, response.getResponseCode());
        }};
    }
}
```

---

## 7. Common Issues & Solutions

### 7.1 Issue: Missing PekkoGuiceSupport for Play 2.9

**Problem:**
```java
import play.libs.pekko.PekkoGuiceSupport; // Does not exist!
```

**Solution 1: Create Custom Support**

```java
package modules;

import com.google.inject.AbstractModule;
import org.apache.pekko.actor.ActorSystem;
import javax.inject.Inject;
import javax.inject.Provider;
import javax.inject.Singleton;

@Singleton
class PekkoGuiceSupportProvider implements Provider<ActorSystem> {
    private final ActorSystem actorSystem;

    @Inject
    public PekkoGuiceSupportProvider(play.Environment environment,
                                      play.inject.ApplicationLifecycle lifecycle) {
        this.actorSystem = ActorSystem.create("application");
        lifecycle.addStopHook(() -> {
            actorSystem.terminate();
            return CompletableFuture.completedFuture(null);
        });
    }

    @Override
    public ActorSystem get() {
        return actorSystem;
    }
}

public abstract class PekkoGuiceSupport extends AbstractModule {
    protected void bindActor(Class<?> actorClass, String name, 
                            Function<Props, Props> propsModifier) {
        bind(ActorRef.class)
            .annotatedWith(Names.named(name))
            .toProvider(new ActorRefProvider(actorClass, name, propsModifier))
            .asEagerSingleton();
    }
}
```

**Solution 2: Use Play 3.0**

Upgrade to Play 3.0 which has native Pekko support.

### 7.2 Issue: Scala Version Mismatch

**Problem:**
```
Binary version mismatch: Expected 2.13, found 2.12
```

**Solution:**
Update all Scala dependencies to 2.13:

```xml
<scala.major.version>2.13</scala.major.version>
<scala.version>2.13.12</scala.version>
```

### 7.3 Issue: Actor Serialization Fails

**Problem:**
```
SerializationException: Cannot find manifest class
```

**Solution:**
Verify serialization bindings in application.conf:

```hocon
pekko.actor.serialization-bindings {
  "org.sunbird.request.Request" = java
  "org.sunbird.response.Response" = java
}
```

### 7.4 Issue: Tests Fail with Timeout

**Problem:**
```
AssertionError: timeout (10 seconds) during expectMsgClass waiting for class Response
```

**Solution:**
Increase timeout or check actor configuration:

```java
import static org.apache.pekko.testkit.javadsl.TestKit.duration;

// Increase timeout
probe.expectMsgClass(duration("30 seconds"), Response.class);
```

---

## 8. Rollback Plan

### 8.1 Git-based Rollback

```bash
# If migration fails, rollback:
git checkout HEAD -- .
git clean -fd

# Or revert to backup
cp -r backup-YYYYMMDD-HHMMSS/* .
```

### 8.2 Staged Deployment Rollback

1. Keep old Docker image available
2. Use blue-green deployment
3. Monitor metrics closely
4. Quick rollback command ready:

```bash
# Kubernetes example
kubectl rollout undo deployment/userorg-service
```

---

## 9. Performance Benchmarks

### 9.1 Pre-Migration Benchmarks

Capture these metrics before migration:

```bash
# Actor throughput
# - Messages per second per actor
# - Average response time
# - 95th percentile latency

# API endpoint performance
# - Request/second
# - Average latency
# - Error rate

# Resource usage
# - Memory consumption
# - CPU usage
# - Thread count
```

### 9.2 Post-Migration Validation

Compare against pre-migration metrics. Acceptable variance: ±10%

---

## 10. Checklist

### Pre-Migration
- [ ] Backup entire codebase
- [ ] Document current architecture
- [ ] Run and save test results
- [ ] Capture performance metrics
- [ ] Review all Akka usage points
- [ ] Plan rollback strategy

### Migration
- [ ] Update all POM files
- [ ] Run automated migration script
- [ ] Manually review all changes
- [ ] Update configuration files
- [ ] Update documentation
- [ ] Fix compilation errors

### Testing
- [ ] Run unit tests
- [ ] Run integration tests
- [ ] Performance testing
- [ ] Load testing
- [ ] Security scanning
- [ ] Manual smoke testing

### Deployment
- [ ] Update CI/CD pipelines
- [ ] Update deployment scripts
- [ ] Staged deployment
- [ ] Monitor logs and metrics
- [ ] Verify all endpoints
- [ ] Rollback if needed

### Post-Deployment
- [ ] Monitor for 48 hours
- [ ] Check error rates
- [ ] Validate performance
- [ ] Collect feedback
- [ ] Document lessons learned

---

## Conclusion

This technical guide provides detailed, actionable steps for migrating from Akka to Pekko. The migration is primarily a package renaming exercise with minimal code changes required. Follow the scripts and checklists provided to ensure a smooth transition.

**Remember:**
- Test thoroughly
- Monitor closely
- Have a rollback plan
- Don't rush the process

For questions or issues, refer to:
- [Apache Pekko Documentation](https://pekko.apache.org/docs/)
- [Play Framework Documentation](https://www.playframework.com/documentation/)
- This repository's main migration report: `MIGRATION_COMPATIBILITY_REPORT.md`
