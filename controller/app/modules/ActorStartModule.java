package modules;

import com.google.inject.AbstractModule;
import org.sunbird.logging.LoggerUtil;

/**
 * Actor binding module for dependency injection.
 * In Play 3.0 with Pekko, actor binding is simplified.
 * Actors are created on-demand via ActorSystem injection.
 */
public class ActorStartModule extends AbstractModule {
  private static LoggerUtil logger = new LoggerUtil(ActorStartModule.class);

  @Override
  protected void configure() {
    logger.debug("ActorStartModule: Actors will be created on-demand via ActorSystem");
    // In Play 3.0, actors are typically accessed via ActorSystem.actorOf()
    // rather than pre-bound via Guice. Controllers inject ActorSystem directly.
  }
}
